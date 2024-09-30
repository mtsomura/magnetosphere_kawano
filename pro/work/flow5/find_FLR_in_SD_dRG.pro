;PRO find_FLR_in_SD_dRG, rPw, dPh
    ; 初期化
    Nevents = 0
    Ndata = N_ELEMENTS(rPw)
    
    ; ピークを検出
    pks_rPwMax = []
    IDed_datNos_rPwMax =[]
    FOR i =1, Ndata -2 do begin
	    IF (rPw[i] GT rPw[i-1]) and (rPw[i] GT rPw[i+1]) then begin
		    pks_rPwMax = [pks_rPwMax, rPw[i]]
		    IDed_datNos_rPwMax = [IDed_datNos_rPwMax, i] 
            ENDIF 
    ENDFOR
print,'pks_rPwMax =', pks_rPwMax
print, 'IDed_datNos_rPwMax =', IDed_datNos_rPwMax

    pks_rPwMin = []
    IDed_datNos_rPwMin =[]
    FOR i =1, Ndata -2 do begin
            IF (rPw[i] LT rPw[i-1]) and (rPw[i] LT rPw[i+1]) then begin
                    pks_rPwMin = [pks_rPwMin, rPw[i]]
                    IDed_datNos_rPwMin = [IDed_datNos_rPwMin, i]
            ENDIF
    ENDFOR
print,'pks_rPwMin =', pks_rPwMin
print, 'IDed_datNos_rPwMin =', IDed_datNos_rPwMin

    pks_dPhMax = []
    IDed_datNos_dPhMax =[]
    FOR i =1, Ndata -2 do begin
            IF (dPh[i] GT dPh[i-1]) and (dPh[i] GT dPh[i+1]) then begin
                    pks_dPhMax = [pks_dPhMax, dPh[i]]
                    IDed_datNos_dPhMax = [IDed_datNos_dPhMax, i]
            ENDIF
    ENDFOR
print,'pks_dPhMax =', pks_dPhMax
print, 'IDed_datNos_dPhMax =', IDed_datNos_dPhMax

    pks_dPhMin = []
    IDed_datNos_dPhMin =[]
    FOR i =1, Ndata -2 do begin
            IF (dPh[i] LT dPh[i-1]) and (dPh[i] LT dPh[i+1]) then begin
                    pks_dPhMin = [pks_dPhMin, dPh[i]]
                    IDed_datNos_dPhMin = [IDed_datNos_dPhMin, i]
            ENDIF
    ENDFOR
print,'pks_dPhMin =', pks_dPhMin
print, 'IDed_datNos_dPhMin =', IDed_datNos_dPhMin


    N_pks_rPwMax = N_ELEMENTS(pks_rPwMax)
    N_pks_rPwMin = N_ELEMENTS(pks_rPwMin)
    N_pks_dPhMax = N_ELEMENTS(pks_dPhMax)
    N_pks_dPhMin = N_ELEMENTS(pks_dPhMin)

print, 'N_pks_rPwMax = ', N_pks_rPwMax
print, 'N_pks_rPwMin = ', N_pks_rPwMin 
print, 'N_pks_dPhMax = ', N_pks_dPhMax
print, 'N_pks_dPhMin = ', N_pks_dPhMin 

    ; 条件チェック
    IF (N_pks_rPwMax EQ 0) OR (N_pks_rPwMin EQ 0) THEN BEGIN
        PRINT, 'No event was identified.'
        Ev_datNos = !VALUES.F_NAN 
	Nevents, Ev_datNos
	RETURN
    ENDIF

    IF (N_pks_dPhMin EQ 0) THEN BEGIN
        PRINT, 'No event was identified.'
        Ev_datNos = !VALUES.F_NAN 
	Nevents, Ev_datNos
	RETURN
    ENDIF

    ; イベントを検出
    FOR iJ = 0, N_pks_rPwMax-1 DO BEGIN
        PRINT, 'iJ is ', iJ, ' now.'
        iJ_found = 0
        IF (N_pks_rPwMax EQ 1) THEN iJ_found = 1 ELSE BEGIN
            IF (iJ EQ 0) THEN BEGIN
                IF (pks_rPwMax[iJ] GT pks_rPwMax[iJ+1]) THEN iJ_found = 1
            ENDIF ELSE IF (iJ EQ N_pks_rPwMax-1) THEN BEGIN
                IF (pks_rPwMax[iJ] GT pks_rPwMax[iJ-1]) THEN iJ_found = 1
            ENDIF ELSE BEGIN
                IF ((pks_rPwMax[iJ] GT pks_rPwMax[iJ-1]) AND (pks_rPwMax[iJ] GT pks_rPwMax[iJ+1])) THEN iJ_found = 1
            ENDELSE
        ENDELSE

        IF (iJ_found EQ 0) THEN BEGIN
            PRINT, 'rPwMax is not larger than adjacent rPwMax''s -> NG.'
            CONTINUE
        ENDIF

        IF (pks_rPwMax[iJ] LT 0.001 OR pks_rPwMax[iJ] GT 1000.0) THEN BEGIN
            PRINT, 'rPwMax is smaller than 0.001 or larger than 1000.0 -> NG.'
            CONTINUE
        ENDIF

        PRINT, iJ, '-th rPw-max may constitute a bipolar rPw.'

        NtimesA = 1.0

        FOR ik = 0, N_pks_rPwMin-1 DO BEGIN
            ik_found = 0
            IF IDed_datNos_rPwMin[ik] LT IDed_datNos_rPwMax[iJ] THEN CONTINUE

            dist_rPwMaxMin = IDed_datNos_rPwMin[ik] - IDed_datNos_rPwMax[iJ]
            dist_rPwMaxMin_maxA = NtimesA * dist_rPwMaxMin

            IF (N_pks_rPwMin EQ 1) THEN BEGIN
                ik_found = 1
                BREAK
            ENDIF ELSE BEGIN
                IF ik EQ 0 THEN BEGIN
                    IF ((IDed_datNos_rPwMin[ik+1] - IDed_datNos_rPwMin[ik]) GT dist_rPwMaxMin_maxA) THEN BEGIN
                        ik_found = 1
                        BREAK
                    ENDIF ELSE BEGIN
                        IF (pks_rPwMin[ik] LT pks_rPwMin[ik+1]) THEN BEGIN
                            ik_found = 1
                            BREAK
                        ENDIF
                    ENDELSE
                ENDIF ELSE IF ik EQ N_pks_rPwMin-1 THEN BEGIN
                    IF ((IDed_datNos_rPwMin[ik] - IDed_datNos_rPwMin[ik-1]) GT dist_rPwMaxMin_maxA) THEN BEGIN
                        ik_found = 1
                        BREAK
                    ENDIF ELSE BEGIN
                        IF (pks_rPwMin[ik] LT pks_rPwMin[ik-1]) THEN BEGIN
                            ik_found = 1
                            BREAK
                        ENDIF
                   ENDELSE
               ENDIF ELSE BEGIN
                   IF ((IDed_datNos_rPwMin[ik+1] - IDed_datNos_rPwMin[ik]) GT dist_rPwMaxMin_maxA) THEN BEGIN
                       IF ((IDed_datNos_rPwMin[ik] - IDed_datNos_rPwMin[ik-1]) GT dist_rPwMaxMin_maxA) THEN BEGIN
                            ik_found = 1
                                BREAK
                        ENDIF ELSE BEGIN
                            IF (pks_rPwMin[ik] LT pks_rPwMin[ik-1]) THEN BEGIN
                                ik_found = 1
                                BREAK
                            ENDIF
                        ENDELSE
		ENDIF ELSE BEGIN
                        IF ((IDed_datNos_rPwMin[ik] - IDed_datNos_rPwMin[ik-1]) LT dist_rPwMaxMin_maxA) THEN BEGIN
                            IF ((pks_rPwMin[ik] LT pks_rPwMin[ik-1]) AND (pks_rPwMin[ik] LT pks_rPwMin[ik+1])) THEN BEGIN
                                ik_found = 1
                                BREAK
                            ENDIF
                        ENDIF ELSE BEGIN
                            IF (pks_rPwMin[ik] LT pks_rPwMin[ik+1]) THEN BEGIN
                                ik_found = 1
                               BREAK
                            ENDIF
                        ENDELSE
                    ENDELSE
                ENDELSE
            ENDELSE
        ENDFOR


        IF (ik_found EQ 0) THEN BEGIN
            PRINT, 'The closest rPw-min was larger than surrounding other rPw-mins -> NG.'
            CONTINUE
        ENDIF

        IF (pks_rPwMin[ik] LT 0.001 OR pks_rPwMin[ik] GT 1000.0) THEN BEGIN
            PRINT, 'rPwMin is smaller than 0.001 or larger than 1000.0 -> NG.'
            CONTINUE
        ENDIF

        PRINT, ik, '-th rPw-min constitutes a bipolar rPw.'
;ENDFOR
        ; 検索範囲を設定
        NtimesB = 0.51
        edge_widthB = FLOOR(NtimesB * dist_rPwMaxMin)
        IF (N_pks_dPhMax GT 0) THEN BEGIN
            datNos_search_sttB = IDed_datNos_rPwMax[iJ] - edge_widthB
            datNos_search_endB = IDed_datNos_rPwMin[ik] + edge_widthB
	    IF datNos_search_sttB GT 1 THEN datNos_search_sttB = datNos_search_sttB ELSE datNos_search_sttB = 1
            datNos_search_endB = MIN(datNos_search_endB, Ndata)

            NdPhMax_in_search_range = 0
            FOR iL = 0, N_pks_dPhMax-1 DO BEGIN
                IF (IDed_datNos_dPhMax[iL] GE datNos_search_sttB AND IDed_datNos_dPhMax[iL] LE datNos_search_endB) THEN BEGIN
                    NdPhMax_in_search_range = NdPhMax_in_search_range + 1
                ENDIF
            ENDFOR

            IF (NdPhMax_in_search_range GT 0) THEN BEGIN
                PRINT, 'dPh-max was found in_or_near the bipolar rPw -> NG.'
                CONTINUE
            ENDIF
        ENDIF

        ; dPh-minを検出
        N_sandwiched_dPhMin = 0
        FOR ja = 0, N_pks_dPhMin-1 DO BEGIN
            IF (IDed_datNos_dPhMin[ja] GT IDed_datNos_rPwMax[iJ] AND IDed_datNos_dPhMin[ja] LT IDed_datNos_rPwMin[ik]) THEN BEGIN
                jb = ja
                N_sandwiched_dPhMin = N_sandwiched_dPhMin + 1
            ENDIF
        ENDFOR

        IF (N_sandwiched_dPhMin NE 1) THEN BEGIN
            PRINT, 'No dPh-min, or more-than-one dPh-mins, were found between the bipolar rPw -> NG.'
            CONTINUE
        ENDIF

        PRINT, 'The ', jb, '-th dPh-min only is between the bipolar rPw.'
        jb_significant = 1
        FOR jc = 0, N_pks_dPhMin-1 DO BEGIN
            IF (IDed_datNos_dPhMin[jc] LT datNos_search_sttB) THEN CONTINUE
            IF (IDed_datNos_dPhMin[jc] GT datNos_search_endB) THEN BREAK

            IF (jc NE jb) THEN BEGIN
                PRINT, 'The ', jc, '-th dPh-min is between datNos_search_sttB and _endB.'
                IF (pks_dPhMin[jc] GT pks_dPhMin[jb]) THEN BEGIN
                    PRINT, 'That dPh-min is larger than the central dPh-min: OK.'
                    CONTINUE
                ENDIF ELSE BEGIN
                    PRINT, 'That dPh-min is smaller than the central dPh-min -> NG.'
                    jb_significant = 0
                    BREAK
	    ENDELSE
            ENDIF
        ENDFOR

        IF (jb_significant EQ 1) THEN BEGIN
            Nevents = Nevents + 1
            IF (Nevents EQ 1) THEN BEGIN
                Ev_datNos = [[IDed_datNos_rPwMax[iJ], IDed_datNos_dPhMin[jb], IDed_datNos_rPwMin[ik]]]
            ENDIF ELSE BEGIN
                Ev_datNos = [[Ev_datNos], [IDed_datNos_rPwMax[iJ], IDed_datNos_dPhMin[jb], IDed_datNos_rPwMin[ik]]]
            ENDELSE
        ENDIF
    ENDFOR

    ; 結果を出力
    IF (Nevents EQ 0) THEN BEGIN
        PRINT, 'No event was identified.'
        Ev_datNos = !VALUES.F_NAN
    ENDIF

    Ev_datNos = FLOAT(Ev_datNos)
    ;Nevents, Ev_datNos
    ;RETURN

;END


