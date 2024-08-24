compile_opt idl3

pro copy_from_matlab, fname_input, Nmovavr

Nmovavr_txt = STRTRIM(STRING(Nmovavr, FORMAT='(I)'))


fname_output = 'hogehoge' + Nmovavr_txt + '.txt'
; hogehoge will be changed after discussing with Kawano-san
; open output file as write
OPENU, lun_output, fname_output, /GET_LUN


; open input file as read
; the structure of input file is 3 columns: freq, rPw, dPh
OPENR, lun_input, fname_input, /GET_LUN

; give the number of columns and rows
n_row = SIZE(FILE_LINES(lun_input), /N_ELEMENTS)
n_col = SIZE(STRSPLIT(READF(lun_input, 1), /EXTRACT), /N_ELEMENTS)
PRINT, n_row, n_col
; if the number of columns is smaller than 3, stop the program
IF n_col LT 3 THEN BEGIN
    PRINT, 'The number of columns is smaller than 3.'
    RETURN

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

; make new function
Nevents, Ev_datNos = find_FLR_in_SD_dRG(rPw, dPh)
; now assuming Nevents and Ev_datNos are returned from the function, Nevents will be integer and Ev_datNos will be array of integers with 3 elements

FOR i = 1, Nevents DO BEGIN
    Nnow_rPwMax = Ev_datNos[i, 0]
    Nnow_dPhMin = Ev_datNos[i, 1]
    Nnow_rPwMin = Ev_datNos[i, 2]

    ; write Nnow_rPwMax, Nnow_dPhMin, Nnow_rPwMin to the output file
    WRITEF, lun_output, Nnow_rPwMax, Nnow_dPhMin, Nnow_rPwMin
    ; write frequency matched to Nnow_rPwMax, Nnow_dPhMin, Nnow_rPwMin to the output file 
    WRITEF, lun_output, freq[Nnow_rPwMax], freq[Nnow_dPhMin], freq[Nnow_rPwMin]
    ; write rPw matched to Nnow_rPwMax, Nnow_dPhMin, Nnow_rPwMin to the output file
    WRITEF, lun_output, rPw[Nnow_rPwMax], rPw[Nnow_dPhMin], rPw[Nnow_rPwMin]
    ; write dPh matched to Nnow_rPwMax, Nnow_dPhMin, Nnow_rPwMin to the output file
    WRITEF, lun_output, dPh[Nnow_rPwMax], dPh[Nnow_dPhMin], dPh[Nnow_rPwMin]
ENDFOR

; close the output file
FREE_LUN, lun_output

end
