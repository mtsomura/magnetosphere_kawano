; this is sample code
PRO plot_wavenumber

; execute init.pro for setting of plotting
@init

; Open the file
; choose filename or the number in filename
file = '../../To_send_from_Kawano/Example_data_correct_add/rPw_dPh_vs_freq_at_RG018_016.movavr_by_02.txt'
OPENR, lun, file, /GET_LUN

; set 3 arrays to store the data in the file
freq = FLTARR(100)
rPw = FLTARR(100)
dPh = FLTARR(100)

; read the data from the file
i = 0
WHILE NOT EOF(lun) DO BEGIN
    READF, lun, freqi, rPwi, dPhi
    freq[i] = freqi
    rPw[i] = rPwi
    dPh[i] = dPhi
    i = i + 1
ENDWHILE

; close the file
FREE_LUN, lun

; delete empty elements in the arrays
freq = freq[0:i-1]
rPw = rPw[0:i-1]
dPh = dPh[0:i-1]


; set the window and set two regions for the plots
WINDOW, XSIZE=500, YSIZE=700
!p.multi = [0, 1, 2]

; plot the data
; 1. freq vs rPw
PLOT, freq, rPw, /YLOG, psym=-1, symsize=1.5, xtitle='Frequency [Hz]', ytitle='rPw [V]'
; 2. freq vs dPh
PLOT, freq, dPh, psym=-1, symsize=1.5, xtitle='Frequency [Hz]', ytitle='dPh [rad]'

end

