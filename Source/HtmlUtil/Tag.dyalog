:Class Tag
⍝ overly simple HTML tag class


    :Field Public Name←''
    :Field Public Attrs←''
    :Field Public Content←''

    noEndTag←'area' 'base' 'br' 'circle' 'col' 'ellipse' 'embed' 'hr' 'img' 'input' 'line' 'link' 'meta' 'param' 'path' 'polygon' 'polyline' 'rect' 'source' 'wbr'

    ∇ make0
      :Access Public
      :Implements Constructor
    ∇

    ∇ make1 args
      :Access Public
      :Implements Constructor
      args←,⊆args
      (Name Attrs Content)←3↑args,(≢args)↓Name Attrs Content
    ∇

    ∇ {r}←Add content;what
      :Access Public
      what←⊃content
      :Select ⊃⎕NC⊂'what'
      :Case 9.2 ⍝ instance
          r←content
      :Case 9.4 ⍝ class
          r←content←⎕NEW content
      :Else
          content←⊂⍕content
          r←⎕THIS
      :EndSelect
      Content,←content
    ∇

    ∇ r←Render;chunk;close
      :Access Public
      close←~(⊂Name)∊noEndTag
      r←'<',Name,(0∊⍴Attrs)↓' ',Attrs,close↓'/>'
      :For chunk :In Content
          :Select ⊃⎕NC'chunk'
          :Case 9
              r,←chunk.Render
          :Case 2
              r,←chunk
          :EndSelect
      :EndFor
      :If close
          r,←'</',Name,'>'
      :EndIf
    ∇

:EndClass
