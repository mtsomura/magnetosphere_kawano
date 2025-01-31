PRO MovingAverage, infile, nmovavr, outfile
  ; 引数のチェック
  IF N_PARAMS() LT 3 THEN BEGIN
    PRINT, 'Usage: MovingAverage, infile, Navr, outfile'
    RETURN
  ENDIF

  ; 入力ファイルを開く
  OPENR, inunit, infile, /GET_LUN
  first_line = ''  ; 最初のヘッダー行をスキップ
  READF, inunit, first_line

  ; データを読み込む
  all_data = []
  WHILE NOT EOF(inunit) DO BEGIN
    line = ''
    READF, inunit, line
    IF STRLEN(line) GT 0 THEN BEGIN
      row_data = FLOAT(STRSPLIT(STRTRIM(line, 2), ' ', /EXTRACT))
      all_data = [[all_data], [row_data]]
    ENDIF
  ENDWHILE
  FREE_LUN, inunit

  ; 配列に変換
  rows = all_data
  Ncols = (SIZE(rows, /DIMENSIONS))(0)  ; 列数を取得
  Ndata = (SIZE(rows, /DIMENSIONS))(1)  ; 行数を取得
 
  PRINT, 'Number of columns = ', Ncols
  PRINT, 'Number of rows    = ', Ndata
  ; 出力ファイルを開く
  OPENW, outunit, outfile, /GET_LUN

 
   result = FLTARR(Ncols,Ndata - nmovavr + 1)
   FOR nf = 0, Ndata - nmovavr DO BEGIN
      FOR kt = 0, Ncols - 1 DO BEGIN
	   FOR l = 0, nmovavr -1 DO BEGIN
	 result[kt,nf] = result[kt,nf] + rows[kt,nf+l]
           ENDFOR
	   result[kt,nf] = result[kt,nf]/nmovavr
      ENDFOR
  ENDFOR
print, result, FORMAT='(F13.8,F15.4,F10.4)'

PRINTF, outunit, result, FORMAT='(F13.8,F15.4,F10.4)'

  FREE_LUN, outunit

END
