 r←test_dropdown dummy;t;values;fail;xml

 xml←⎕XML'id="xyz"'#.HtmlUtil.DropDown⊂'abc' 'def'
 :If xml[;2]≢'select' 'option' 'option'
     →0⊣r←'Incorrect tag names'
 :ElseIf xml[;3]≢'' 'abc' 'def'
     →0⊣r←'Incorrect values'
 :ElseIf xml[;4]≢1 2∘⍴¨('id' 'xyz')('value' 'abc')('value' 'def')
     r←'Incorrect options'
 :Else
     r←''
 :EndIf
