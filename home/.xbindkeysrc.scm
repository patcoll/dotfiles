; NOTE: add `xbindkeys` to `.xinitrc`

; bind shift + vertical scroll to horizontal scroll events
(xbindkey '(shift "b:4") "xte 'mouseclick 6'")
(xbindkey '(shift "b:5") "xte 'mouseclick 7'")

; (xbindkey '(mod4 "c:25") "xte 'keydown Control_L' 'key w' 'keyup Control_L'")
