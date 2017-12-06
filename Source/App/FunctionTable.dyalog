 r←fn FunctionTable n;values;f
 values←⍳n
 f←⍎fn
 r←(fn,values)⍪values,∘.f⍨values
