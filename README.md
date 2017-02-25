# Trace
A multi-dimensional real time data plotter

Version 1.0: Plots any number of measurements vs time; like a multi-channel oscilloscope. This version offers little flexibility, and is primarily intended as a demo or as a starting point for your own additions.

This version expects data to be streaming over a COM port at startup.
Data is expected as integers in a CSV format; whitespace will be cleaned.
Each index in a given line of measurements (i.e. 1, 2, 3, ...) will be plotted as a trace.
Theoretically, any number of traces can be created.
