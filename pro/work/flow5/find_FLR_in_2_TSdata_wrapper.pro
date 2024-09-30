;PRO find_FLR_in_2_TSdata_wrapper, rPw_dPh_file, Nmovavr
    ; フォーマットされた文字列を作成
    print,'Input Nmovavr'
    read,Nmovavr
    NmovavrTxt = STRING(Nmovavr, FORMAT='(I2.2)')

    ; 出力ファイルの作成
    OutFile = 'autoIDed_FLR_list.freq_movavr_by_' + NmovavrTxt + '.txt'
    OPENW, lun_out, OutFile, /GET_LUN

    ; 入力ファイルの読み込み
    InFile = 'rPw_dPh_vs_freq_movavr_by_' + NmovavrTxt + '.txt'
    PRINT, InFile
    
    ; ファイルを開く
    OPENR, unit, InFile , /GET_LUN

    ; ファイル内容を読み込む
    data = ''
    text = ''
    while not eof(unit) do begin
        readf, unit, data
        text = text + ' ' + data
    endwhile

    free_lun, unit

    ; 区切りの文字列を数値配列に変換
    numbers = float(strsplit(text, ' ', /extract))

    ; 配列の要素数を確認
    n_elements = N_ELEMENTS(numbers)

    ; 要素数が3の倍数か確認
    IF n_elements MOD 3 NE 0 THEN BEGIN
        PRINT, 'エラー: 要素数が3の倍数ではありません。'
        RETURN
    ENDIF

    ; 配列を3行に並び替える
    n_row = n_elements / 3
    f_rPw_dPh = REFORM(numbers, 3, n_row)

    ; 結果を表示
    PRINT, '3行に並び替えた配列:'
    PRINT,  f_rPw_dPh
    N_size = SIZE(f_rPw_dPh)
    n_col = N_size[1]
    print, 'n_row =', n_row
    print, 'n_col =', n_col
    freq = FLTARR(100)
    rPw = FLTARR(100)
    dPh = FLTARR(100)

  
    IF n_col LT 3 THEN BEGIN
        PRINT, 'n_col<3'
        
    ENDIF

    ; データの分割
    freq = f_rPw_dPh[0 ,*]
    rPw  = f_rPw_dPh[1 ,*]
    dPh  = f_rPw_dPh[2 ,*]
print, 'freq =' ,freq
print, 'rPw =' ,rPw
print, 'dPh =' ,dPh

    ; FLRイベントの検出
   ; find_FLR_in_SD_dRG, rPw, dPh
    @find_FLR_in_SD_dRG
    ; 検出されたイベントの処理
   FOR jk = 0, Nevents-1 DO BEGIN
        Nnow_rPwMax = Ev_datNos[0, jk]
        Nnow_dPhMin = Ev_datNos[1, jk]
        Nnow_rPwMin = Ev_datNos[2, jk]

        ; データをファイルに書き込む
        PRINTF, lun_out, FORMAT='(I5,I5,I5)', Nnow_rPwMax, Nnow_dPhMin, Nnow_rPwMin
        PRINTF, lun_out, FORMAT='(F12.7,F12.7,F12.7)', freq[Nnow_rPwMax], freq[Nnow_dPhMin], freq[Nnow_rPwMin]
        PRINTF, lun_out, FORMAT='(F16.3,F16.3,F16.3)', rPw[Nnow_rPwMax], rPw[Nnow_dPhMin], rPw[Nnow_rPwMin]
        PRINTF, lun_out, FORMAT='(F16.3,F16.3,F16.3)', dPh[Nnow_rPwMax], dPh[Nnow_dPhMin], dPh[Nnow_rPwMin]
        PRINTF, lun_out, ''
    ENDFOR
;Print, 'Ev_datNos =',Ev_datNos
    CLOSE, OutFile
    ; ファイルを閉じる
    FREE_LUN, lun_out
END
