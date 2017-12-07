 r←test_fntable dummy;t;values;fail;fn
 values←⍳15
 r←''
 ⎕PP←2
 :For fn :In #.App.functionList
     fail←16 16≢⍴fn #.App.FunctionTable 15
     r,←fail/⊂'FunctionTable failed for "',fn,'"'
 :EndFor
