; PRO plot_colormap
;     ; Create sample data
;     nx = 100
;     ny = 100
;     data = FLTARR(nx, ny)

;     ; Fill the data with some values
;     FOR i = 0, nx-1 DO BEGIN
;         FOR j = 0, ny-1 DO BEGIN
;             data[i, j] = SIN(i/10.0) * COS(j/10.0)
;         ENDFOR
;     ENDFOR

;     ; Create a window
;     WINDOW, 0, XSIZE=600, YSIZE=600

;     ; Plot the colormap
;     TVSCL, data

;     ; Add a color bar
;     LOADCT, 5
;     COLORBAR, /VERTICAL, POSITION=[0.85, 0.1, 0.9, 0.9]

;     ; Add labels
;     ; XYOUTS, 50, 550, 'Sample 2D Colormap', /DEVICE, ALIGNMENT=0.5
;     ; XYOUTS, 50, 50, 'X-axis', /DEVICE, ALIGNMENT=0.5
;     ; XYOUTS, 50, 50, 'Y-axis', /DEVICE, ALIGNMENT=0.5
;     ; set the plotgraphics with XOUTS of NORMAL
;     XYOUTS, 0.5, 0.5, 'X-axis', /NORMAL, ALIGNMENT=0.5
;     XYOUTS, 0.5, 0.5, 'Y-axis', /NORMAL, ALIGNMENT=0.5


; END
PRO plot_colormap

;  read files at ../../To_send_from_Kawano/Example_data_correct_add/Beam01 and named sd_han_vlos_2_bm01rg{No_of_RG}_clip_degap_deflag_tclip.VLOS.FFT.txt
; the column 1, 2, 3, 4, 5 is the frequency, the real part of the power, the imaginary part of the power, the amplitude of the power, the phase of the power
; No_of_RG is ranged from 000 to 067
num_rg = 68

n_initialize = 16
; Initialize arrays to store the data
frequency = FLTARR(n_initialize, num_rg)
real_part = FLTARR(n_initialize, num_rg)
imaginary_part = FLTARR(n_initialize, num_rg)
amplitude = FLTARR(n_initialize, num_rg)
phase = FLTARR(n_initialize, num_rg)

; Loop over the range gates
FOR rg = 0, num_rg-1 DO BEGIN
    ; Construct the filename
    filename = 'sd_han_vlos_2_bm01rg' + STRING(rg, FORMAT='(I3.3)') + '_clip_degap_deflag_tclip.VLOS.FFT.txt'
    filedir = '../../To_send_from_Kawano/Example_data_correct_add/Beam01/'
    filepath = filedir + filename

    ; Open the file
    ; OPENR, data, filepath, /GET_LUN
    
    ; Check if the file exists before opening
    checkfile = file_test(filepath, get_mode = read)
    IF NOT checkfile THEN BEGIN
        PRINT, 'File does not exist: ', filepath
        CONTINUE
    ENDIF

    ; Open the file
    OPENR, data, filepath, /GET_LUN

    ; read columns from the file with while loop
    i = 0
    WHILE NOT EOF(data) DO BEGIN
        READF, data, frequencyi, real_parti, imaginary_parti, amplitudei, phasei
        frequency[i, rg] = frequencyi
        real_part[i, rg] = real_parti
        imaginary_part[i, rg] = imaginary_parti
        amplitude[i, rg] = amplitudei
        phase[i, rg] = phasei
        i = i + 1
    ENDWHILE

    print, 'the column length of the data is ', i

    ; Close the file
    FREE_LUN, data

    ; ; Delete empty elements in the arrays
    ; frequency[rg, *] = frequency[rg, 0:i-1]
    ; real_part[rg, *] = real_part[rg, 0:i-1]
    ; imaginary_part[rg, *] = imaginary_part[rg, 0:i-1]
    ; amplitude[rg, *] = amplitude[rg, 0:i-1]
    ; phase[rg, *] = phase[rg, 0:i-1]
ENDFOR

s = size(amplitude,/DIM)
nx = s[0]
ny = s[1]
x = findgen(nx)
y = findgen(ny)

; Create a window
www = window(dim=[500,500])

; Set the colormap
loadct, 5

; plot the image
iiimg = image(amplitude, x, y, /CURRENT, position=[0.1, 0.1, 0.9, 0.9], rgb_table=33,$
    axis_style=2,$
    xstyle=1, ystyle=1,$
    xcolor='black', ycolor='black',$
    xtitle='Frequency (Current barely indices)', ytitle='Range gate', title='Amplitude of the power',$
    xtickdir=1, ytickdir=1)
; iiimg.colorbar, /VERTICAL, position=[0.95, 0.1, 1.0, 0.9]
END
