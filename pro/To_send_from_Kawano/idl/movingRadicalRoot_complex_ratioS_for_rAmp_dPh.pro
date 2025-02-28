pro movingRadicalRoot_complex_ratioS_for_rAmp_dPh, horiz_ax_var, $
                                                  Areals,Aimags, $
                                                  Breals,Bimags, $
                                                  Navr, $
                                                  movavr_horiz_ax_var, $
                                                  movRR_rAmp, movRR_dPh, ID_OK

; 「累乗根」＝「べき乗根」＝「1/n乗」は英語では「radical root」と言う。
;  上記下記中の movRR は movingRadicalRoot の略

; Navr は整数、他の変数は全て行ベクトル。要素数は、
; Areals, Aimags, Breals, Bimags は同じ。
; movrAmp, dPh の要素数は Navr が増えるほど減っていく; 関係式は下記
;           (moving_average.pro を参考に書いた)
  
  Acmplxs = DCOMPLEX(Areals,Aimags)
  Bcmplxs = DCOMPLEX(Breals,Bimags)
  Rcmplxs = Acmplxs / Bcmplxs
  log_Rcmplxs = ALOG(Rcmplxs)

  moving_average,        horiz_ax_var,        log_Rcmplxs, Navr, $
                  movavr_horiz_ax_var, movavr_log_Rcmplxs, ID_OK

  movRR_Rcmplxs = EXP(movavr_log_Rcmplxs)
  movRR_rAmp    =  ABS(movRR_Rcmplxs)
  movRR_dPh     = ATAN(movRR_Rcmplxs,/PHASE)*!radeg

END
