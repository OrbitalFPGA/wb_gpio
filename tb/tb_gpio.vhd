library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.TextIO.all;
use ieee.std_logic_textio.all; -- write, hwrite

entity tb_gpio is
end entity;

architecture test of tb_gpio is
    constant WB_DATA_WIDTH             : integer  := 32;
    constant WB_REGISTER_ADDRESS_WIDTH : integer  := 16;
    constant CLK_FREQ                  : positive := 200_000_000; -- (1/CLK_FREQ) should not have repeating decimals
    constant CLK_PERIOD                : time     := (1.0/real(CLK_FREQ)) * 1 sec;

    constant GPIO_DIRECTION_OFFSET : std_logic_vector(15 downto 0) := x"0020";
    constant GPIO_DATA_OFFSET      : std_logic_vector(15 downto 0) := x"0024";

    constant all_output : std_logic_vector(WB_DATA_WIDTH - 1 downto 0) := (others => '0');
    constant all_input  : std_logic_vector(WB_DATA_WIDTH - 1 downto 0) := (others => '1');

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal address            : std_logic_vector(WB_REGISTER_ADDRESS_WIDTH - 1 downto 0) := (others => '0');
    signal write_data         : std_logic_vector(WB_DATA_WIDTH - 1 downto 0)             := (others => '0');
    signal read_data          : std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
    signal write_enable       : std_logic := '0';
    signal read_enable        : std_logic := '0';
    signal ack                : std_logic;
    signal stall              : std_logic;
    signal gpio_pins          : std_logic_vector(WB_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal pin_change         : std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
    signal pin_change_capture : std_logic_vector(WB_DATA_WIDTH - 1 downto 0);
    signal tmp                : std_logic_vector(WB_DATA_WIDTH - 1 downto 0);

begin

    ----------------------
    -- Clock Generation --
    ----------------------

    gen_clk : clk <= not clk after (CLK_PERIOD/2);

    gpio_dut : entity work.gpio
        port map
        (
            i_clk         => clk,
            i_reset       => rst,
            i_ip_address  => address,
            o_ip_rdata    => read_data,
            i_ip_read_en  => read_enable,
            i_ip_wdata    => write_data,
            i_ip_write_en => write_enable,
            o_ip_ack      => ack,
            o_ip_stall    => stall,
            io_gpio       => gpio_pins,
            o_pin_change  => pin_change
        );

    stall_stay_low : process
    begin
        loop
            wait until rising_edge(clk);
            assert stall = '0'
            report "ERROR: stall went high"
                severity error;
        end loop;
    end process;

    tb : process

        procedure print_time(msg : string) is
            variable L               : line; -- used for console output in case of error
        begin
            write(L, now); -- label: where does this start?
            write(L, string'(": "));
            write(L, string'(msg));
            writeline(output, L);
        end procedure print_time;

        procedure read_register (
            addr         : in std_logic_vector(15 downto 0);
            signal rdata : out std_logic_vector(31 downto 0)
        ) is
        begin
            wait until rising_edge(clk);
            address     <= addr;
            read_enable <= '1';
            wait until rising_edge(clk);
            read_enable <= '0';
            wait until falling_edge(clk);
            if (ack = '0') then
                print_time("ERROR: Expected read to be acknoledged");
            end if;
            rdata <= read_data;
            wait until rising_edge(clk);
        end procedure read_register;

        procedure write_register (
            addr  : in std_logic_vector(15 downto 0);
            wdata : in std_logic_vector(31 downto 0)
        ) is
        begin
            wait until rising_edge(clk);
            address      <= addr;
            write_data   <= wdata;
            write_enable <= '1';
            wait until rising_edge(clk);
            write_enable <= '0';
            wait until falling_edge(clk);
            if (ack = '0') then
                print_time("ERROR: Expected write to be acknoledged");
            end if;
            wait until rising_edge(clk);
        end procedure;

        procedure change_direction (
            wdata : in std_logic_vector(31 downto 0)
        ) is
        begin
            for x in 0 to 31 loop
                if wdata(x) = '0' then
                    gpio_pins(x) <= 'Z';
                else
                    gpio_pins(x) <= '0';
                end if;
            end loop;
            write_register(GPIO_DIRECTION_OFFSET, wdata);
        end procedure;
    begin
        -------------------------------------
        -- Reset & Initialization
        -------------------------------------
        print_time("TEST: Applying reset");
        rst <= '1';
        wait for 8 * CLK_PERIOD;
        rst <= '0';
        wait for 8 * CLK_PERIOD;

        -------------------------------------
        -- Set all GPIOs as outputs and drive high
        -------------------------------------
        print_time("TEST: Setting all GPIOs as outputs and writing 0xAAAAAAAA");
        -- write_register(GPIO_DIRECTION_OFFSET, all_output);
        change_direction(all_output);
        write_register(GPIO_DATA_OFFSET, x"AAAAAAAA"); -- alternating 1s and 0s
        read_register(GPIO_DATA_OFFSET, tmp);
        if (tmp /= x"AAAAAAAA") then
            print_time("ERROR: Output readback mismatch");
        end if;

        -------------------------------------
        -- Change some GPIOs to inputs
        -------------------------------------
        print_time("TEST: Setting lower half GPIOs as inputs, upper half as outputs. Writing all 1s.");
        -- Set lower half (15 downto 0) as inputs, upper half (31 downto 16) as outputs
        write_register(GPIO_DIRECTION_OFFSET, x"0000FFFF");

        -- Attempt to write to input pins (should be ignored)
        write_register(GPIO_DATA_OFFSET, x"FFFFFFFF");

        -- Read data, only upper half should reflect outputs
        read_register(GPIO_DATA_OFFSET, tmp);
        if (tmp(31 downto 16) /= x"FFFF") then
            print_time("ERROR: Output upper half not reflecting write");
        end if;
        -- Lower half is input, we simulate their values below

        -------------------------------------
        -- Simulate external input change and check pin_change
        -------------------------------------
        print_time("TEST: Simulating input transition from low to high on lower half GPIOs");
        -- External values: drive inputs from testbench
        gpio_pins(15 downto 0) <= x"0000"; -- set low
        wait for 4 * CLK_PERIOD;
        gpio_pins(15 downto 0) <= x"FFFF"; -- transition to high (should trigger pin_change)

        pin_change_capture <= (others => '0');
        for i in 1 to 4 loop
            wait until rising_edge(clk);
            pin_change_capture <= pin_change_capture or pin_change;
        end loop;

        -- Capture o_pin_change
        if (pin_change_capture(15 downto 0) /= x"FFFF") then
            print_time("ERROR: Expected pin_change not triggered on rising edge");
        end if;

        print_time("TEST: Simulating input transition from high to low on lower half GPIOs");
        gpio_pins(15 downto 0) <= x"0000"; -- transition to low

        pin_change_capture <= (others => '0');
        for i in 1 to 4 loop
            wait until rising_edge(clk);
            pin_change_capture <= pin_change_capture or pin_change;
        end loop;
        if (pin_change_capture(15 downto 0) /= x"FFFF") then
            print_time("ERROR: Expected pin_change not triggered on falling edge");
        end if;

        -- Confirm pin_change pulses only once
        print_time("TEST: Checking that pin_change clears after one cycle");
        wait for 2 * CLK_PERIOD;
        if (pin_change /= x"00000000") then
            print_time("ERROR: pin_change should be cleared after one clock");
        end if;
        -------------------------------------
        -- Final test: dynamic direction switch
        -------------------------------------
        print_time("TEST: Switching directions dynamically to 0x00FF00FF");
        -- Switch a few pins from output to input
        write_register(GPIO_DIRECTION_OFFSET, x"00FF00FF");
        gpio_pins(23 downto 16) <= x"00";
        wait for 2 * CLK_PERIOD;
        read_register(GPIO_DATA_OFFSET, tmp);
        if (tmp(23 downto 16) /= x"00") then
            print_time("ERROR: Former output data bits still set");
        end if;

        -- Drive testbench pins, verify data reflects input changes
        print_time("TEST: Driving lower 8 GPIOs externally and reading back");
        gpio_pins(7 downto 0) <= x"AA";
        wait for 2 * CLK_PERIOD;
        read_register(GPIO_DATA_OFFSET, tmp);
        if (tmp(7 downto 0) /= x"AA") then
            print_time("ERROR: Input readback mismatch on lower byte");
        end if;

        print_time("Simulation Done");
        wait until true;
    end process tb;

end test;