 r←ScriptFollows;lines;pgm;from
⍝ Treat following commented lines in caller as a script, lines beginning with ⍝⍝ are stripped out
 :If 0∊⍴lines←(from←⎕IO⊃⎕RSI).⎕NR pgm←2⊃⎕SI
     lines←↓from.(180⌶)pgm
 :EndIf
 r←2↓∊CRLF∘,¨{⍵/⍨'⍝'≠⊃¨⍵}{1↓¨⍵/⍨∧\'⍝'=⊃¨⍵}dtlb¨(1+2⊃⎕LC)↓lines
