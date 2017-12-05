 r←{attr}Table data
 attr←{6::⍵ ⋄ attr}''
 r←('table',(0∊⍴attr)↓' ',attr)Enclose∊'tr'∘Enclose¨{∊{'td'∘Enclose,⍕⍵}¨⍵}¨↓data
