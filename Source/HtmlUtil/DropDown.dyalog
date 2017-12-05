 r←{attr}DropDown args;choices;chosen
 args←,⊆args
 (choices chosen)←2↑args,(⍴args)↓'' ''
 attr←{6::⍵ ⋄ attr}''
 r←('select ',attr)Enclose∊(,⍕chosen)∘{⍺{('option value="',⍵,'"',(⍺≡⍵)/' selected="selected"')Enclose ⍵},⍕⍵}¨choices
