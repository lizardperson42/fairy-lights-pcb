# fairy-lights-pcb

This repository contains the PCB design files for the fairy lights project.
The project is a set of fairy lights that is attached to a custom PCB and controlled by an ESP8266 microcontroller.
The PCB design files are created using KiCad.

## Parts

- [WeMos D1 Mini ESP8266](https://www.wemos.cc/en/latest/d1/d1_mini.html) (1 unit)
- DC barrel jack, 5.5mm x 2.0mm (1 unit)
- Screw terminals, 5mm pitch, 4-pin and/or 3-pin (up to 1 unit of each size)
- Pin header, 2.54mm pitch, 1x2 pins (1 unit)
- Pin headers, 2.54mm pitch, 1x4 pins and 2x4 pins (up to 1 unit each)
- WS2812B SMD LEDs (0 or 4 units)
- Vertical tactile push buttons (up to 2 units)
- THT resistors (10kΩ, 0 or 2 units)

### Notes

- The WeMos D1 Mini module can be mounted in various ways.
  The CAD model used here connects it via pin sockets and headers.
- One could leave out the barrel jack, but without it most of the board becomes redundant.
- The screw terminals are used to attach connectors for the LED strands, which use wire-to-wire connectors.
- The 2-pin header is interposed between the power jack and the board's 5V rail.
  One can wire up a power switch to it or short it with a jumper.
- The optional pin headers expose the pins of the WeMos D1 Mini module which are not used otherwise.
- The SMD LEDs are connected in a chain around the board; it is not useful to populate only some of them.
- The buttons are directly connected to the microcontroller's GPIO pins.
  - Button USER_A places the microcontroller into flashing mode when pressed during boot-up.
    After boot-up, it can be used to wake the microcontroller from standby mode.
  - Button USER_B cannot trigger standby wake-ups (its state can only be read by polling in software).
- The 4-pin header is connected to the microcontroller's conventional I²C bus pins and the 3.3V rail.
  The THT resistors, if populated, pull its clock and data lines up.
  Without the resistors, the 4-pin header simply exposes the two GPIO pins.
  Together with the 8-pin header's 5V pin, the 4-pin header can be used to drive another LED strand instead.

## Accessories

- 5V DC power supply, at least 2A recommended, matching the barrel jack
- WS2801 LED strand, JST SM 4-pin connector, particularly [this one](https://www.adafruit.com/product/322) (optional)
- WS2812 LED strand, JST SM 3-pin connector (optional)

> [!IMPORTANT]
> This board powers the LED strands and on-board LEDs from the 5V rail but controls them using 3.3V signals straight from the ESP8266.
> This pushes the envelope of what their WS28xx driver chips are documented to support.
> This arrangement might work unreliably or not all.

## Connector and microcontroller pin overview

The PCB has the following connectors:

- J1: 5V DC power input, at least 2A recommended, pin positive, sleeve negative.
- J2: SPI LED strand connector, 5V power, 3.3V signals.
  - Data line is tied to MCU pin D7 (GPIO13).
  - Clock line is tied to MCU pin D5 (GPIO14).
- J3: WS2812 LED strand connector, 5V power, 3.3V signals.
  - Data line is tied to MCU pin D6 (GPIO12).
- J4: I²C connector, 3.3V power and signals.
  - Data line is tied to MCU pin D2 (GPIO4).
  - Clock line is tied to MCU pin D1 (GPIO5).
- J5: Miscellaneous connector. Layout and MCU pin mapping:
  ```
   GND |1 2| RST
    5V |3 4| A0
  3.3V |5 6| D0
    RX |7 8| TX
  ```
  (pin D0 is also tied to button USER_B)
- SW1: Power switch, separates barrel jack from 5V rail when open.

The microcontroller's pins are used as follows:

Name        | Function              | Connector
------------+-----------------------+------------------------
GND         | Common ground         | J1; J2; J3; J4; J5; USB
5V          | 5V rail               | J1; J2; J3; J5; USB
3.3V        | 3.3V rail             | J4; J5
RST         | Reset                 | J5
RX (GPIO3)  | UART receive          | J5; via USB
TX (GPIO1)  | UART transmit         | J5; via USB
A0 (ADC0)   | Analog input          | J5
D0 (GPIO16) | Button                | SW3 (USER_B)
D1 (GPIO5)  | I²C clock             | J4
D2 (GPIO4)  | I²C data              | J4
D3 (GPIO0)  | Button; MCU flashing  | SW2 (USER_A)
D4 (GPIO2)  | MCU module LED        | none
D5 (GPIO14) | SPI clock             | J2
D6 (GPIO12) | WS2812 data           | J3
D7 (GPIO13) | SPI data              | J2
D8 (GPIO15) | On-board WS2812B LEDs | none

“USB” refers to the MCU module's on-board USB connector, if any.
