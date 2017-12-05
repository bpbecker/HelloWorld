 r←{attr}Slider minmax;min;max;value
 attr←{6::⍵ ⋄ attr}''
 (min max value)←3⍴minmax
 r←(⍕min),' <input ',attr,' type="range" min="',(⍕min),'" max="',(⍕max),'" value="',(⍕value),'"/> ',⍕max
