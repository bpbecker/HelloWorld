 r←{attr}Table data
 attr←{6::⍵ ⋄ attr}''
 r←('table ',attr)Enclose∊'tr'∘Enclose¨{∊'td'∘Enclose¨,⍕⍵}¨↓data
