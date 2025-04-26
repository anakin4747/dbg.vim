
# Bugs

## DeinitJob tries to close closed windows

If you close the debugger and debuggee windows manually and then StopDebugger
gets called (via :Dbg or :DbgStop) this error occurs:
```
Error detected while processing function <SNR>46_Dbg[39]..StopDebugger[2]..DeinitJob:
line    2:
E5555: API call: Invalid window id: 1582
```
This should be cleanly handled and provide an info message of the situation.

## UpdateConfig fails since mkdir is not down on no config
