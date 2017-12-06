 r←test_fntable dummy;t;values;fail;fn
 values←⍳15
 r←''
 :For fn :In #.App.functionList
     t←fn #.App.FunctionTable 15
     fail←t≢(fn,values)⍪values,∘.(⍎fn)⍨values
     r,←fail/⊂'FunctionTable failed for "',fn,'"'
 :EndFor
