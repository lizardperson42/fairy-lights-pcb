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
- The buttons are directly connected to the microcontroller's GPIO pins and do nothing on their own.
- The 4-pin header is connected to the microcontroller's conventional I²C bus pins and the 3.3V rail.
  The THT resistors, if populated, pull its clock and data lines up.
  Without the resistors, the 4-pin header simply exposes the two GPIO pins.
  Together with the 8-pin header's 5V rail, the 4-pin header can be used to drive another LED strand instead.

## Accessories

- 5V DC power supply, at least 2A recommended, matching the barrel jack
- WS2801 LED strand, JST SM 4-pin connector, particularly [this one](https://www.adafruit.com/product/322) (optional)
- WS2812 LED strand, JST SM 3-pin connector (optional)

> [!IMPORTANT]
> This board powers the LED strands and on-board LEDs from the 5V rail but controls them using 3.3V signals straight from the ESP8266.
> This pushes the envelope of what their WS28xx driver chips are documented to support.
> This arrangement might work unreliably or not all.
