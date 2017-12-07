 r←fn FunctionTable n;values;f;⎕PP
 values←⍳n
 f←⍎fn
 ⎕PP←2
 r←⍕¨(fn,values)⍪values,∘.{0::'oof' ⋄ ⍺ f ⍵}⍨values
