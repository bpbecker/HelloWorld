 r←HelloMath args;submitOnChange;fn;values;html;evt;req;resp;setup;fntab;max
⍝ Produce function tables using the HTMLRenderer

 :If setup←0∊⍴args ⍝    Empty args: Create an instance of HTMLRenderer
     evt←'Event' 'HTTPRequest' 'HelloMath'
     'hr'⎕WC'HTMLRenderer'('URL' 'HelloMath')('Coord' 'ScaledPixel')('Size' 550 700)evt

 :Else             ⍝    Non-empty: Callback, generate HTML for form
     ⍝ Process input data
     req←⎕NEW #.HttpUtils.HttpRequest args   ⍝ create a request from the callback data
     (fn max)←req.(FormData∘Get)¨'fn' 'max'
     fn←⊃fn,'+'
     max←⊃10,⍨⊃(//)⎕VFI max ⍝ convert to number, use 10 as default

     ⍝ Business Logic
     fntab←fn FunctionTable max

     ⍝ Generate HTML content
     html←'<title>Hello Math!</title>'
     html,←'<form id="myForm" method="post" action="HelloMath">'
     submitOnChange←'onchange="document.getElementById(''myForm'').submit()"'
     html,←'Function: ',('name="fn" autofocus ',submitOnChange)#.UI.DropDown functionList fn
     html,←'<br/>Range: ',('name="max" ',submitOnChange)#.UI.Slider 1 15,max
     html,←'<br/><br/>','div'#.UI.Enclose #.UI.Table fntab
     html,←'</form>'

     resp←⎕NEW #.HttpUtils.HttpResponse args ⍝ create a response based on the request
     resp.Content←html
     r←resp.ToHtmlRenderer                   ⍝ Format suitable response to callback
 :EndIf
