# Trace
A multi-dimensional, real time data plotter and logger, for real world data.

Use: Connect some source of CSV serial data to your computer (ex. Arduino, STM Nucleo, MSP430, etc.)
Run Trace.
Select a dimension, then select a measurement to map to that dimension.
Do this for as many dimensions as are desired.
Click "Add Trace" to create the trace made from this information.
Add as many traces as are desired.
Click "Done" when finished to view the traces.

Version 2_0: Adds multiple dimensions, as well as user definition of traces.
The startup screen allows the user to create traces by selecting the which incoming measurements map to which dimensions.
This version offers 10 dimension options (X, Y, Z, Thickness, Opacity, Grayscale, RGB, Red, Green, Blue).

Version 1.0: Plots any number of measurements vs time; like a multi-channel oscilloscope. This version offers little flexibility, and is primarily intended as a demo or as a starting point for your own additions.

This version expects data to be streaming over a COM port at startup.
Data is expected as integers in a CSV format; whitespace will be cleaned.
Each index in a given line of measurements (i.e. 1, 2, 3, ...) will be plotted as a trace.
Theoretically, any number of traces can be created.
