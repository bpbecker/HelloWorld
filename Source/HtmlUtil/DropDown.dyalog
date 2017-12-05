 r←{attr}DropDown choices
 attr←{6::⍵ ⋄ attr}''
 r←('select ',attr)Enclose∊{{('option value="',⍵,'"')Enclose ⍵}⍕⍵}¨choices
