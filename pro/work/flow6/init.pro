;; set plot style using X
set_plot, 'x'

;; set background to white and color to black
!p.background = 255
!p.color = 0

;; set color map for 24-bit display
device, decomposed=0, retain=2, true_color=24
loadct, 5, /si


