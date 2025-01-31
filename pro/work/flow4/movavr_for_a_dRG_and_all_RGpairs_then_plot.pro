PRO process_data, RGmin, RGmax, dRG, Nmovavr
    ; 出力フォルダの名前を設定
    folder_for_output = './amovavr_by_' + STRING(FORMAT='(I02)', Nmovavr)
    
    ; フォルダが存在するか確認
    IF FILE_TEST(folder_for_output, /DIRECTORY) THEN BEGIN
        PRINT, folder_for_output + ' already exists: Check its contents. Stopped'
        RETURN
    ENDIF ELSE BEGIN
        FILE_MKDIR, folder_for_output
        CD, folder_for_output
    ENDELSE

    ; 作図結果フォルダの名前を設定
    folder_for_fig_output = './rPw_dPh_vs_freq.movavr_by_' + STRING(FORMAT='(I02)', Nmovavr) + '.Figs'
    
    ; 作図フォルダが存在するか確認
    IF FILE_TEST(folder_for_fig_output, /DIRECTORY) THEN BEGIN
        PRINT, folder_for_fig_output + ' already exists: Check its contents. Stopped'
        RETURN
    ENDIF ELSE BEGIN
        FILE_MKDIR, folder_for_fig_output
    ENDELSE

    ; RGの範囲でループ
    FOR RG = RGmin, RGmax - dRG DO BEGIN
        PRINT, '$RG = ', RG

        ; ファイル名の生成
        fncmnprt = 'rPw_dPh_vs_freq_at_RG' + STRING(FORMAT='(I03)', RG + dRG) + '_' + STRING(FORMAT='(I03)', RG)
        InFile = '../' + fncmnprt + '.txt'
        OutFile = fncmnprt + '.movavr_by_' + STRING(FORMAT='(I02)', Nmovavr) + '.txt'

        ; 出力ファイルの作成
        OPENW, unit, OutFile, /GET_LUN
        CLOSE, unit
        FREE_LUN, unit

        ; 移動平均スクリプトの実行
        movingaverage, infile ,nmovavr, outfile
        

        ; グラフのファイル名を生成
        FigFile = folder_for_fig_output + '/' + fncmnprt + '.movavr_by_' + STRING(FORMAT='(I02)', Nmovavr) + '.png'

        PRINT, 'OutFile = ', OutFile
        PRINT, 'FigFile = ', FigFile

        ; gnuplotで記載していた部分→描画の必要なし?
    ENDFOR
END

