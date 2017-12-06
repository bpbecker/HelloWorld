 r←fn FunctionTable n;values;f;⎕PP
 values←⍳n
 f←⍎fn
 ⎕PP←2
 r←⍕¨(fn,values)⍪values,∘.f⍨values
