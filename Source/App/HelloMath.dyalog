 r←HelloMath args;submitOnChange;fn;values;html;evt;req;resp;setup
 submitOnChange←'onchange="document.getElementById(''myForm'').submit()"'
 :If setup←0∊⍴args ⍝ setup
     evt←'Event' 'HTTPRequest' 'HelloMath'
     'hr'⎕WC'HTMLRenderer'('Coord' 'ScaledPixel')('Size' 400 400)evt
 :Else ⍝ callback, get values from form data
     req←⎕NEW #.HttpUtils.HttpRequest args   ⍝ create a request from the callback data
     resp←⎕NEW #.HttpUtils.HttpResponse args ⍝ create a response based on the request
     (fn values)←req.(FormData∘Get)¨'fn' 'values'
     fn←⊃fn,'+'
     values←⊃10,⍨⊃(//)⎕VFI values ⍝ convert to number, use 10 as default
     html←'<title>Hello Math!</title>'
     html,←'<form id="myForm" method="post" action="HelloMath">'
     html,←'Select a function: ',('name="fn" ',submitOnChange)#.HtmlUtil.DropDown'+-×÷!⌈⌊|<≤=≥>≠'
     html,←'<br/>Values to display: ',('name="values" ',submitOnChange)#.HtmlUtil.Slider 2 15 10
     html,←'div'#.HtmlUtil.Table fn FunctionTable values
     html,←'</form>'
     resp.Content←html
     r←resp.ToHtmlRenderer                   ⍝ and send it back
 :EndIf
