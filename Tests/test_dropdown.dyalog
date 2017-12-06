 r←test_dropdown dummy;t;values;fail;xml

 xml←⎕XML'id="xyz"'HtmlUtil.DropDown⊂'abc' 'def'
 →0 Because'Incorrect tag names'If xml[;2]≢'select' 'option' 'option'
 →0 Because'Incorrect values'If xml[;3]≢'' 'abc' 'def'
 →0 Because'Incorrect options'If xml[;4]≢1 2∘⍴¨('id' 'xyz')('value' 'abc')('value' 'def')
