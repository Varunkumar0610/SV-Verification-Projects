# SV Verification Projects

## Overview
This repository contains various SystemVerilog (SV) verification projects that focus on different digital design modules, including bus protocols, communication protocols, and basic building blocks like FIFO and DFF. These projects showcase advanced verification techniques such as constrained random testing, coverage-driven verification, and assertions.

## Projects Included

### 1. **Bus Protocols Verification**
   - **Description**: Verification of common bus protocols, including AXI and APB, focusing on ensuring data integrity, address mapping, and protocol compliance.
   - **Sub-Projects**:
     - **AXI Protocol**: Verification of the AXI protocol's read and write channels, handling burst transfers, handshakes, and address mapping.
     - **APB Protocol**: Verification of the APB protocol, ensuring correct timing and data transfer operations in peripheral communication.

### 2. **Communication Protocols Verification**
   - **Description**: Verification of common communication protocols, including SPI, I2C, and UART, ensuring reliable data transfer and correct signal timing.
   - **Sub-Projects**:
     - **SPI Protocol**: Verification of the SPI protocol, focusing on master/slave communication, clock synchronization, and data integrity.
     - **I2C Protocol**: Verification of the I2C protocol, ensuring proper multi-master communication, addressing, and clock stretching.
     - **UART Protocol**: Verification of UART, ensuring accurate data transmission and reception, including handling of baud rate and framing.

### 3. **FIFO Verification**
   - **Description**: Verification of a First-In, First-Out (FIFO) buffer, focusing on testing proper data storage, overflow, and underflow conditions.
   - **Sub-Projects**:
     - **Basic FIFO**: Verifying the operation of a basic FIFO buffer with correct push/pop operations.
     - **Advanced FIFO**: Testing advanced FIFO features, such as depth control, reset functionality, and handling of edge cases like full/empty conditions.

### 4. **D Flip-Flop (DFF) Verification**
   - **Description**: Verification of the D Flip-Flop (DFF) design, ensuring proper edge-triggered functionality and handling of setup/hold times.
   - **Sub-Projects**:
     - **Basic DFF**: Verification of the basic functionality of a D Flip-Flop, focusing on correct edge triggering and data capture.
     - **Advanced DFF**: Testing of advanced DFF configurations, including asynchronous reset and enable features.

## IHI0011 AMBA Specification
Refer from the attached **IHI0011 AMBA Specification.pdf**, which provides a comprehensive guide to the **AMBA (Advanced Microcontroller Bus Architecture)**, a set of protocols used to design high-performance systems. This specification covers protocols like **AMBA APB (Advanced Peripheral Bus)** and **AMBA AXI (Advanced Extensible Interface)**.

### AMBA APB (Advanced Peripheral Bus)
   - **Description**: APB is a simple, low-bandwidth, and low-power bus interface used primarily for connecting peripheral devices to a processor. It is optimized for ease of use, with a low implementation cost and is suitable for connecting slower peripherals like UART, timers, or GPIOs. APB supports basic read and write operations with simpler handshakes compared to other bus types.
   - **Key Features**:
     - Simple and low-power design.
     - Single master/slave communication.
     - Synchronous operation, typically with slower clock speeds.
     - Supports basic read/write operations with minimal signal complexity.

### AMBA AXI (Advanced Extensible Interface)
   - **Description**: AXI is a high-performance, high-bandwidth bus protocol designed for use in modern high-speed applications. It supports high-frequency and high-throughput data transfer and is optimized for parallel operations and low-latency data paths. AXI is often used to connect high-performance modules like memory controllers, DSPs, and GPUs in complex system designs.
   - **Key Features**:
     - Supports multiple read and write channels (read, write, and write-back).
     - Supports out-of-order transaction completion for improved performance.
     - Supports burst transactions, which can significantly improve the efficiency of data transfers.
     - Provides low-latency data transfers with separate read and write address/control channels.
     - Allows for multiple masters to initiate transfers concurrently.

The AMBA specification ensures that components in ARM-based systems can communicate efficiently using standardized bus protocols. APB is ideal for simpler, lower-power peripherals, while AXI is suited for high-performance, high-bandwidth interconnects.

## Tools and Methodologies
- **HDL**: SystemVerilog
- **Verification Methodology**: Constrained random testing, directed testing, functional coverage, assertions, etc.
- **Simulation Tools**: Synopsys VCS, Questasim (running in MobaXterm).
- **Verification Standards**: IEEE 1800 or other relevant standards (if followed).

## Getting Started
### Prerequisites
- A SystemVerilog-compatible simulation tool (e.g., Synopsys VCS, Questasim).
- Basic knowledge of SystemVerilog and digital design principles.

### How to Run
Follow these steps to run the project:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Varunkumar0610/SV-Verification-Projects.git
   
2. **Navigate to the project folder**:
   ```bash
   cd project-folder-name
   
3. **Run the simulation**:
   ```bash
   make run 
