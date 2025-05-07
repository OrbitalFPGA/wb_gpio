--===================================================================
--  File: gpio.vhd
--  Author: Michael B
--  Description: Handles the GPIO signals for wb_gpio core
--  Date: May 04, 2025
--===================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity gpio is
    generic (
        WB_DATA_WIDTH               : integer                            := 32;
        WB_REGISTER_ADDRESS_WIDTH   : integer                            := 16;
        DEFAULT_GPIO_DIRECTION_FULL : std_logic_vector(127 - 1 downto 0) := (others => '1');
        DEFAULT_GPIO_OUTPUT_FULL    : std_logic_vector(127 - 1 downto 0) := (others => '0')
    );
    port (
        i_clk   : in std_logic;
        i_reset : in std_logic;

        i_ip_address  : in std_logic_vector((WB_REGISTER_ADDRESS_WIDTH - 1) downto 0);
        o_ip_rdata    : out std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
        i_ip_read_en  : in std_logic;
        i_ip_wdata    : in std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
        i_ip_write_en : in std_logic;
        o_ip_ack      : out std_logic;
        o_ip_stall    : out std_logic;

        io_gpio      : inout std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
        o_pin_change : out std_logic_vector((WB_DATA_WIDTH - 1) downto 0)

    );
end entity;

architecture rtl of gpio is

    constant GPIO_DIRECTION_OFFSET                : integer := 16#0020#;
    constant GPIO_DATA_OFFSET                     : integer := 16#0024#;
    signal direction_register                     : std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
    signal gpio_data                              : std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
    signal gpio                                   : std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
    signal sycn_gpio_ff                           : std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
    signal sycn_gpio                              : std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
    signal sycn_gpio_delay                        : std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
    signal gpio_change                            : std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
    signal gpio_data_write_value                  : std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
    signal gpio_data_write_value_direction_change : std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
    signal gpio_data_read_value                   : std_logic_vector((WB_DATA_WIDTH - 1) downto 0);
    -- Sliced default constants
    constant DEFAULT_GPIO_DIRECTION : std_logic_vector(WB_DATA_WIDTH - 1 downto 0) :=
    DEFAULT_GPIO_DIRECTION_FULL(WB_DATA_WIDTH - 1 downto 0);
    constant DEFAULT_GPIO_OUTPUT : std_logic_vector(WB_DATA_WIDTH - 1 downto 0) :=
    DEFAULT_GPIO_OUTPUT_FULL(WB_DATA_WIDTH - 1 downto 0);

begin

    begin_check_widths : process
    begin
        assert (WB_DATA_WIDTH = 8 or WB_DATA_WIDTH = 16 or WB_DATA_WIDTH = 32 or
        WB_DATA_WIDTH = 64 or WB_DATA_WIDTH = 128)
        report "Unsupported WB_DATA_WIDTH: must be one of 8,16,32,64,128."
            severity failure;
        wait;
    end process;

    -- Mask i_ip_data to ensure only pins configured as output can be written to
    gpio_data_write_value                  <= i_ip_wdata and (not direction_register);
    gpio_data_write_value_direction_change <= gpio_data and (not i_ip_wdata);
    -- Logic to to write to registers
    process (i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_reset = '1') then
                direction_register <= DEFAULT_GPIO_DIRECTION;
                gpio_data          <= DEFAULT_GPIO_OUTPUT;
            elsif (i_ip_write_en = '1') then
                case TO_INTEGER(unsigned(i_ip_address)) is
                    when GPIO_DIRECTION_OFFSET =>
                        direction_register <= i_ip_wdata;
                        gpio_data          <= gpio_data_write_value_direction_change;
                    when GPIO_DATA_OFFSET =>
                        gpio_data <= gpio_data_write_value;
                    when others =>
                end case;
            end if;
        end if;
    end process;

    -- Syncronize GPIO data to i_clk domain
    process (i_clk)
    begin
        if rising_edge(i_clk) then
            sycn_gpio_ff    <= io_gpio;
            sycn_gpio       <= sycn_gpio_ff;
            sycn_gpio_delay <= sycn_gpio;
        end if;
    end process;
    gpio_change  <= (sycn_gpio_delay xor sycn_gpio) and direction_register;
    o_pin_change <= gpio_change;

    -- Drive pins configured as output
    process (direction_register, gpio_data)
    begin
        for x in 0 to WB_DATA_WIDTH - 1 loop
            if (direction_register(x) = '0') then -- '0' = Output enable Input disabled, '1' = Output disabled Input enabled
                gpio(x) <= gpio_data(x);
            else
                gpio(x) <= 'Z';
            end if;
        end loop;
    end process;

    io_gpio <= gpio;

    -- Logic to read registers
    -- process (i_ip_read_en, i_ip_address, direction_register, sycn_gpio)
    process (i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_reset = '1') then
                o_ip_rdata <= (others => '0');
                -- direction_register <= std_logic_vector(to_unsigned(DEFAULT_GPIO_DIRECTION, WB_DATA_WIDTH));
                -- gpio_data          <= std_logic_vector(to_unsigned(DEFAULT_GPIO_OUTPUT, WB_DATA_WIDTH));
            elsif (i_ip_read_en = '1') then
                case TO_INTEGER(unsigned(i_ip_address)) is
                    when GPIO_DIRECTION_OFFSET =>
                        o_ip_rdata <= direction_register;
                    when GPIO_DATA_OFFSET =>
                        o_ip_rdata <= sycn_gpio;
                    when others           =>
                        o_ip_rdata <= (others => '0');
                end case;
                -- else
                -- o_ip_rdata <= (others => '0');
            end if;
        end if;
    end process;

    process (i_clk)
    begin
        if rising_edge(i_clk) then
            if (i_reset = '1') then
                o_ip_ack <= '0';
            else
                o_ip_ack <= i_ip_read_en or i_ip_write_en;
            end if;
        end if;
    end process;

    o_ip_stall <= '0';
end architecture;