PRO read_superDARN
; IDL script to read SuperDARN data which is after the reduction

rdir = '/PATH TO DATA DIR/magnetosphere_kawano/pro/To_send_from_Kawano/Example_data_correct_add/Beam01/dRG=02/'

; Read the data
; The data are stored as 3 columns: Power, Phase, and Frequency
; In the directory "rdir", there are 63 files, for instance, named as "rPw_dPh_vs_freq_at RGnnn_mmm.txt".
; For each loop, we read the data of each column and store them in the variables "Pw", "Ph", and "freq".
; After the reading all data files, we store them in the variables "Pw_all", "Ph_all", and "freq_all".

Pw_all = fltarr(0)
Ph_all = fltarr(0)
freq_all = fltarr(0)


for i=0,62 do begin
  if i lt 10 then begin
    RG = '0'+strtrim(i,2)
  endif else begin
    RG = strtrim(i,2)
  endelse
  file = rdir+'rPw_dPh_vs_freq_at_RG'+RG+'_001.txt'
  if file_test(file) eq 0 then begin
    print, 'File not found: ', file
    continue
  endif
  data = read_ascii(file, /silent)
  Pw = data[*,0]
  Ph = data[*,1]
  freq = data[*,2]
  if i eq 0 then begin
    Pw_all = Pw
    Ph_all = Ph
    freq_all = freq
  endif else begin
    Pw_all = [Pw_all, Pw]
    Ph_all = [Ph_all, Ph]
    freq_all = [freq_all, freq]
  endelse
endfor

; The data are stored in the variables "Pw_all", "Ph_all", and "freq_all"



END
