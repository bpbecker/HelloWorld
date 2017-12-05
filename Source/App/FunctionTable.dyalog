 r←fn FunctionTable values
 values←⍳values
 r←(fn,values)⍪values,⍎'∘.',fn,'⍨values'
