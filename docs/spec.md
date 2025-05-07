# Wishbone B4 GPIO Specification 

**IP Name:** wb_gpio

**Version:** 1.0

**Author:** Michael B.

**Date:** May 4, 2025

---

## 1. Overview
The `wb_gpio` is a memory-mapped General Purpose Input/Output (GPIO) peripheral that interfaces with a Wishbone B4 bus. It allows software to configure each pin as either input or output, read the input values, and write output values. The peripheral supports configurable direction per pin and includes interrupt support for input state changes. 

## 2. Functional Requirements
| ID          | Requirement Description                               |
| ----------- | ----------------------------------------------------- |
| REQ-FUNC-01 | Provide control over 32 GPIO pins                     |
| REQ-FUNC-02 | Allow configuration of each pin's direction           |
| REQ-FUNC-03 | Allow reading input values                            |
| REQ-FUNC-04 | Allow writing output values                           |
| REQ-FUNC-05 | Support interrupt generation on input change          |
| REQ-FUNC-06 | Comply with the Wishbone B4 Pipeline specification as a subordinate|


## 3. Non-Functional Requirements
| ID           | Requirement Description                               |
| ------------ | ----------------------------------------------------- |
| REQ-NFUNC-01 | Synthesizable VHDL                                    |
| REQ-NFUNC-02 | Fully synchronous to `i_wb_clk`                       |


## 4. Interface Definition

### 4.1 Parameters
| Name                      | Default Value | Description                                                      |
| ------------------------- | ------------- | ---------------------------------------------------------------- |
| WB_ADDRESS_WIDTH          | 32            | Number of bits in address                                        |
| WB_BASE_ADDRESS           | 0x4001_0000   | Base address of interface/IP                                     | 
| WB_REGISTER_ADDRESS_WIDTH | 16            | Number of least-significant address bits used for register space |
| WB_DATA_WIDTH             | 32            | Number of bits in data bus                                       |
| WB_DATA_GRANULARITY       | 8             | Smallest unit of transfer interface support                      |
| IP_VERSION                | WB_DATA_WIDTH | Value to expose in the VERSION Register                          |
| IP_DEVICE_ID              | WB_DATA_WIDTH | Value to expose in the DEVICE_ID Register                        |
| DEFAULT_GPIO_DIRECTION    | 0xFFFF_FFFF  | What direction should the GPIO be set to on reset; bit[x] = Output when '0'               |
| DEFAULT_GPIO_OUTPUT       | 0x0000_0000   | What direction should the GPIO be set to on reset                |


### 4.2 Wishbone Signals
| Signal  | Direction | Width                                | Description         |
| ------- | --------- | ------------------------------------ | ------------------- |
| i_wb_clk   | Input     | 1                                    | System Clock        |
| i_wb_rst   | Input     | 1                                    | Active-high reset   |
| i_wb_cyc   | Input     | 1                                    | Bus cycle indicator | 
| i_wb_stb   | Input     | 1                                    | Data Strobe signal  |
| i_wb_we    | Input     | 1                                    | Write Enable        |
| i_wb_addr  | Input     | WB_ADDRESS_WIDTH                     | Address Bus         |
| i_wb_dat   | Input     | WB_DATA_WIDTH                        | Data input Bus      |
| i_wb_sel   | Input     | WB_DATA_WIDTH  / WB_DATA_GRANULARITY | Data select         | 
| o_wb_dat   | Output    | WB_DATA_WIDTH                        | Data output Bus     |
| o_wb_stall | Output    | 1                                    | Stall signal        | 
| o_wb_ack | Output    | 1                                    | Acknowledge      | 

### 4.3 IP Signals
| Signal  | Direction | Width                                | Description         |
| ------- | --------- | ------------------------------------ | ------------------- |
| io_gpio   | InOut     | WB_DATA_WIDTH                      | Bidirectional GPIO pin interface |
| o_interrupt | Output  | 1                                  | Interrupt signal, active high, Bitwise-OR of IRQ register  |  

## 5. Register Map
| Offset | Name         | Description                                 | R/W  |
| ------ | ------------ | ------------------------------------------- | ---- |
| 0x00   | VERSION      | Version number of IP                        | R    | 
| 0x04   | DEVICE_ID    | Unique 32-bit identifier for IP             | R    |
| 0x08   | CONTROL      | Control bits for module operation           | R/W  |  
| 0x0C   | IRQ_MASK     | Enable bits for interrupt sources           | R/W  |  
| 0x10   | IRQ          | Latched interrupt status                    | R/WC |  
| 0x14   | STATUS       | Status bits (ready, busy, error, etc.)      | R    |  
| 0x18   | RESERVED     | RESERVED                                    | R    |  
| 0x1C   | RESERVED     | RESERVED                                    | R    |
| 0x20   | DIRECTION    | Sets the direction of GPIO pin              | R/W  |
| 0x24   | GPIO_DATA    | GPIO data register                          | R/W  | 

R/WC: Read/Write 1 to bit to clear

### 5.1 Control Register
| Bit  | Field Name       | Access Type | Reset Value | Description |
| ---- | ---------------- | ----------- | ----------- | ----------- |
| 31   | Global Interrupt Enable | Read/Write  | 1           | Enables interrupts for core, 1 = Enable | 

### 5.2 IRQ_MASK Register
| [WB_DATA_WIDTH-1:0]   | Interrupt mask | Read/Write  | 0xFFFF_FFFF           | If pin is configured as input, when set to '1', a change in the pin value will generate an interrupt | 

### 5.3 Direction Register
| Bit  | Field Name       | Access Type | Reset Value | Description |
| ---- | ---------------- | ----------- | ----------- | ----------- |
| [WB_DATA_WIDTH-1:0]   | GPIOx_direction | Read/Write  | DEFAULT_GPIO_DIRECTION           | Each pin is individually programmable for input or output. 0 = I/O pin configured as output, 1 = I/O pin configured as input | 


### 5.4 GPIO Data Register
| Bit  | Field Name       | Access Type | Reset Value | Description |
| ---- | ---------------- | ----------- | ----------- | ----------- |
| [WB_DATA_WIDTH-1:0]   | GPIOx_data | Read/Write  | DEFAULT_GPIO_OUTPUT           | I/O pin as input: R: Read value of pin, W: No effect. I/O pin as output: R: Value being outputed, W: Write value to corresponding GPIO pin |

## 6. Timing Diagrams

## 7. Verification Strategy
Develop a self-checking VHDL testbench that includes:
- Read/write test sequences for all registers
- Direction control toggling and behavior verification
- GPIO output driving and input sampling
- Interrupt generation on simulated pin toggles
- Edge case behavior (reset, simultaneous reads/writes)


## 8. Future Enhancements


## 9. Change History

| Version | Date             | Changes                   |
|---------|----------------  |---------------------------|
| 1.0     | April 18, 2025   | Initial draft             |

## 10. References

- [Wishbone B4 Specification](https://cdn.opencores.org/downloads/wbspec_b4.pdf), OpenCores, Revision B4.
- [Wishbone Interface Logic](https://github.com/OrbitalFPGA/wb-subordinate-if-sv)