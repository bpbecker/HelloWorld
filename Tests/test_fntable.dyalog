 r←test_fntable dummy;t;values;fail
 t←'+'#.App.FunctionTable 5
 values←⍳5
 fail←t≢('+',values)⍪values,∘.+⍨values
 r←0 Because fail/'Wrong result from FunctionTable'
