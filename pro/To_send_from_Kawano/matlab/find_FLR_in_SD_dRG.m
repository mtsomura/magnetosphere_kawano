function [Nevents,Ev_datNos] = find_FLR_in_SD_dRG(rPw,dPh)
%
%	1つ前の version との差：
%        ・NtimesDA の値を 0.3 → 0.51 に。
%        ・Ntimes   を NtimesA に rename.
%        ・NtimesDA を NtimesB に rename.
%
%	以下は、memo.SuperDARN_FLR.txt/ref708 を改良した同定基準。
%
%	 ・ rPw 極大値がその両隣の rPw 極大値より大きく、更に、
%	 ・ その隣の rPw 極小値がその両隣の rPw 極小値より小さい bipolar peak
%	   	       （HAN Beam #1 では (+/-)、に対応）が必要。
%	 ・ その範囲内の dPh の極小が1つだけである事が必要。更に、
%	 ・ その dPh 極小値がその両隣の dPh 極小値より小さい事が必要。
%
%	 を満たす dPh極小データ のデータ番号を見つけて Ev_datNos(:,2) に記録
%	 する関数。（折角なので、それを挟む bipolar rPw のデータ番号も記
%	 録：低周波側が Ev_datNos(:,1), 高周波側が Ev_datNos(:,3)。
%
%       ※ rPw,dPhともに、最初と最初の極値については例外処理となる。
%
%       (Note inserted  2019/May/24(Fri)/19:59 ,
%       (Corrected at 2019/Sep/09(Wed)/00:51) ori24にて、
%       近隣の peak との振幅比によるevent取捨に、以下の条件追加した：
%       ・「rPwMaxと、それより高周波数側で最も近いrPwMinの間隔」の 
%              NtimesA 倍より遠くにある
%             「今見ているrPwMinの両隣のrPwMin」は 
%             「今見ているrPwMinが一番小さい値を持っているか否か」の
%              判断基準としない。
%              （残った隣のrPwMin (最大2個) を比較対象とする）
%               (memo.SuperDARN_FLR.txt/ref764 (2019/May/24(Fri))、
%                  ref797 (2019/May/24(Fri)) も関連あり)
%
%       (Note inserted 2019/Jun/01(Sat)/17:24-20:16) ori25にて、
%       ・何か、ori24 は re764 の実装に bug ありっぽいので、直してみて、
%       　　　　テストし終える所までやった。
%
%       (Note inserted 2019/Oct/21(Mon)/12:21) ori30にて、
%       ・「rPwMaxと、それより高周波数側で最も近いrPwMinの間隔」の 
%             NtimesB 倍を両脇に含めた範囲内(:=
%             「datNos_search_sttB〜datNos_search_endB」の範囲に
%       　　  他のdPhMaxがあるイベントは捨てるようにした。
%               (memo.SuperDARN_FLR.txt/798,781,777)
%
%       (Note inserted 2021/Feb/10(Wed)/23:31 (実際の coding はこれより
%             ずっと前) 上記の
% >	 ・ その dPh 極小値がその両隣の dPh 極小値より小さい事が必要。
%             を ori31 (前回JpGU まで使用の ver.) より精密化した(→下記(b))：
%
%           (a) rPwMax〜rPwMin 範囲内に dPhMin (位相差の極小値) が1つだけ存在する、
%           (b) その dPhMin が以下のどちらかを満たす：
%	        (b1) datNos_search_sttB〜datNos_search_endB の範囲内に
%	             他 の dPhMin が存在しない、
%	      OR
%	        (b2) datNos_search_sttB〜datNos_search_endB の範囲内に
%	             他の dPhMin's が存在する場合、それらより
%	             (a)の dPhMin が小さい
%
%       (Note inserted 2021/Mar/02(Tue)/23:12
%            rPw が bipolar でも、0.001 < rPwMax, rPwMin < 1000 の範囲内に
%            無い event は捨てるようにした。


Nevents = 0;
Ndata = length(rPw);
format compact;
[pks_rPwMax,IDed_datNos_rPwMax] = findpeaks( rPw);
[pks_rPwMin,IDed_datNos_rPwMin] = findpeaks(-rPw); pks_rPwMin = -pks_rPwMin;
[pks_dPhMax,IDed_datNos_dPhMax] = findpeaks( dPh);
[pks_dPhMin,IDed_datNos_dPhMin] = findpeaks(-dPh); pks_dPhMin = -pks_dPhMin;

IDed_datNos_rPwMax
pks_rPwMax
IDed_datNos_rPwMin
pks_rPwMin
IDed_datNos_dPhMax
pks_dPhMax
IDed_datNos_dPhMin
pks_dPhMin

N_pks_rPwMax = numel(pks_rPwMax); % これの loop 変数は iJ
N_pks_rPwMin = numel(pks_rPwMin); % これの loop 変数は ik
N_pks_dPhMax = numel(pks_dPhMax); % これの loop 変数は iL
N_pks_dPhMin = numel(pks_dPhMin); % これの loop 変数は im


if ((N_pks_rPwMax == 0) || (N_pks_rPwMin == 0))
    disp('No event was identified.');
    Ev_datNos = NaN;  %「Nevents = 0」は上で設定されている
    return;
end

if (N_pks_dPhMin == 0)
    disp('No event was identified.');
    Ev_datNos = NaN;  %「Nevents = 0」は上で設定されている
    return;
end

for iJ = 1:N_pks_rPwMax
    fprintf('iJ is %d now.¥n',iJ);

    % まず、周波数の関数としての突出した極大点 of rPw を探す
    iJ_found = 0;
    if (N_pks_rPwMax == 1)  % 極大点1個のケース：自動的に「突出した極大点」になる
        iJ_found = 1;
    elseif (N_pks_rPwMax == 2)  % 極大点2個のケース
        if (iJ == 1)  % 最初の rPw 極大値の例外処理
            if (pks_rPwMax(iJ) > pks_rPwMax(iJ+1))
                iJ_found = 1;
            end
        else  % つまり、(iJ = N_pks_rPwMax = 2) の場合 = 最後の rPw 極大値の例外処理
            if (pks_rPwMax(iJ) > pks_rPwMax(iJ-1))
                iJ_found = 1;
            end
        end
    else  % 極大点3個以上のケース
        if (iJ == 1)  %「最初の2個」で判断するケース
            if (pks_rPwMax(iJ) > pks_rPwMax(iJ+1))
                iJ_found = 1;
            end
        elseif (iJ == N_pks_rPwMax)  %「最後の2個」で判断するケース
            if (pks_rPwMax(iJ) > pks_rPwMax(iJ-1))
                iJ_found = 1;
            end
        else  % → iJ 番目の極大点が両隣の極大点より突出しているか判断する
            if ((pks_rPwMax(iJ) > pks_rPwMax(iJ-1))  && ...
                (pks_rPwMax(iJ) > pks_rPwMax(iJ+1)))
                iJ_found = 1;
            end
        end
    end

    % この行で iJ_found == 0 だと、iJ 番目の極大点は突出していなかったとい
    % う事なので、iJ loop の次 の iJ へ進む。
    if (iJ_found == 0)
        disp('rPwMax is not larger than adjacent rPwMax''s -> NG.');
        continue
    end

    if ((pks_rPwMax(iJ)<0.001) || (pks_rPwMax(iJ)>1000.0))
        % 極大値自体が小さすぎるか大きすぎて2点法結果の信頼性が低いので、次の iJ loop に移る
        disp('rPwMax is smaller than 0.001 or larger than 1000.0 -> NG.');
        continue
    end
    
    fprintf('%d-th rPw-max may constitute a bipolar rPw.¥n',iJ);
    
    % それの高周波側で一番近い 極小点 of rPw を探す

    NtimesA = 1.0;  % 下記で使う。試行錯誤で決めるべき数字。1は「とりあえず」。
                    % ref781 でとりあえずそう決めた後、1度も試行錯誤していない。

    for ik = 1:N_pks_rPwMin
        ik_found = 0;

        if IDed_datNos_rPwMin(ik) < IDed_datNos_rPwMax(iJ)
            continue   % → ik loop の次の ik に移る
        end

        % この行に到達した = 隣接した極小点 of rPw が見つかった at データ番号 = ik
        % (1つも見つからずにこの ik loop を出る場合もある。)
        
        % その 極小点 における rPw (極小値) が突出しているか調べる

        % まず、見つかった極大点〜極小点間の距離 dist_rPwMaxMin (← freq
        % 方向の datNos で 数える) を求める 
        %        (memo.SuperDARN_FLR.txt/ref764 (2019/May/24(Fri))、
        %                                ref781 (2019/May/24(Fri)))
        % ***Line01***
        dist_rPwMaxMin = IDed_datNos_rPwMin(ik)-IDed_datNos_rPwMax(iJ);

        dist_rPwMaxMin_maxA = NtimesA * dist_rPwMaxMin;  % 隣の rPwMin が近いか遠いかの threhsold

        if N_pks_rPwMin == 1  % → 1つしか rPwMin が無いので、自動的に突出した rPwMin になる。ので、
                              % ID である ik_found を 1 にして ik loop を出る
            ik_found = 1; break;
        else
            if ik == 1  % 最初の rPw 極小値である場合の例外処理
                if ((IDed_datNos_rPwMin(ik+1) - ...
                     IDed_datNos_rPwMin(ik)) > ...
                        dist_rPwMaxMin_maxA)  % → ik は孤立 min. なので、この点が求めていた極小点。
                    ik_found = 1; break;
                else  % 孤立 min. で無い場合
                    if (pks_rPwMin(ik) < pks_rPwMin(ik+1))  % → ik で rPwMin が突出。なので、この点が求めていた極小点。
                        ik_found = 1; break;
                    end
                end
            elseif ik == N_pks_rPwMin  % 最後の rPw 極小値である場合の例外処理
                if ((IDed_datNos_rPwMin(ik) - ...
                     IDed_datNos_rPwMin(ik-1)) > ...
                        dist_rPwMaxMin_maxA)  % → ik は孤立 min. なので、この点が求めていた極小点。
                    ik_found = 1; break;
                else  % 孤立 min. で無い場合
                    if (pks_rPwMin(ik) < pks_rPwMin(ik-1))  % → ik で rPwMin が突出。なので、この点が求めていた極小点。
                        ik_found = 1; break;
                    end
                end
            else   % 最初でも最後でもない rPw 極小値である場合の処理
                % 以下、IDed_datNos_rPwMin(ik+1)を選定基準に使わないケース。
                if ((IDed_datNos_rPwMin(ik+1) - ...
                     IDed_datNos_rPwMin(ik)) > ...
                        dist_rPwMaxMin_maxA)  % → IDed_datNos_rPwMin(ik+1)は選定基準に使わない
                    if ((IDed_datNos_rPwMin(ik) - ...
                         IDed_datNos_rPwMin(ik-1)) > ...
                            dist_rPwMaxMin_maxA)  % → IDed_datNos_rPwMin(ik-1)も選定基準に使わない。つまり ik は孤立 min. なので、この点が求めていた極小点。
                        ik_found = 1; break;
                    else  % → IDed_datNos_rPwMin(ik-1)のみ選定基準に使う
                        if (pks_rPwMin(ik) < pks_rPwMin(ik-1))  % → ik で突出している事になるのでこの点が求めていた極小点。
                            ik_found = 1; break;
                        end
                    end
                % 以下、IDed_datNos_rPwMin(ik+1)を選定基準に使うケース。
                else
                    if ((IDed_datNos_rPwMin(ik) - ...
                         IDed_datNos_rPwMin(ik-1)) < ...
                        dist_rPwMaxMin_maxA)  % → IDed_datNos_rPwMin(ik-1)も判断基準に使う
                        if ((pks_rPwMin(ik) < pks_rPwMin(ik-1)) &&  ...
                            (pks_rPwMin(ik) < pks_rPwMin(ik+1)))  % → ik で突出している事になるのでこの点が求めていた極小点。
                            ik_found = 1; break;
                        end
                    else  % → IDed_datNos_rPwMin(ik-1)は選定基準に使わない
                        if (pks_rPwMin(ik) < pks_rPwMin(ik+1))  % → ik で突出している事になるのでこの点が求めていた極小点。
                            ik_found = 1; break;
                        end
                    end
                end
            end
        end
    end  % end of the ik loop

    if ik_found == 0
        disp('The closest rPw-min was larger than surrounding other rPw-mins -> NG.');
        continue   % 隣接した突出した極小が見つからなかったので、次の iJ loop に移る
    end

    if ((pks_rPwMin(ik)<0.001) || (pks_rPwMin(ik)>1000.0))
        % 極小値自体が小さすぎるか大きすぎて2点法結果の信頼性が低いので、次の iJ loop に移る
        disp('rPwMin is smaller than 0.001 or larger than 1000.0 -> NG.');
        continue
    end

    fprintf('%d-th rPw-min constitutes a bipolar rPw.¥n',ik);
    
    % この行に到達した = 設定した条件を満たす rPw (+/-) pair が見つかり、
    % IDed_datNos_rPwMax(iJ) が極大点のデータ番号、
    % IDed_datNos_rPwMin(ik) が極小点のデータ番号、と判った。次に、

    % dist_rPwMaxMin (上方、Line01で定義されている) の範囲の両脇に
    % (NtimesB * dist_rPwMaxMin範囲) を加えた範囲
    % (下記 datNos_search_sttB〜datNos_search_endB の範囲)
    %
    % の中に dPhMax が存在しない事を要求する。
    %    (ref: memo.SuperDARN_FLR.txt/ref781 (2019/May/24(Fri)),
    %          ref789 (2019/May/24(Fri), ref764 (2019/May/24(Fri)) も関連あり)
    %
    % NtimesB は試行錯誤で決めるべき値。ここでは0.51にしてある ←
    %    sample data を使った試行錯誤の結果 (ref882 (2019/Oct/21(Mon)))。

    % (2019/Jun/02(Sun)/08:42, ref805 の7行上) round を floor で差し替えた←
    %    これも試行錯誤の結果。

    NtimesB = 0.51;
    edge_widthB = floor((NtimesB * dist_rPwMaxMin));

    if N_pks_dPhMax > 0
        datNos_search_sttB = IDed_datNos_rPwMax(iJ) - edge_widthB;
        datNos_search_endB = IDed_datNos_rPwMin(ik) + edge_widthB;
        datNos_search_sttB = max(datNos_search_sttB,     1);
        datNos_search_endB = min(datNos_search_endB, Ndata);

        NdPhMax_in_search_range = 0;
        for iL = 1:N_pks_dPhMax
            if ((IDed_datNos_dPhMax(iL) >= datNos_search_sttB)  && ...
                (IDed_datNos_dPhMax(iL) <= datNos_search_endB))
                NdPhMax_in_search_range = NdPhMax_in_search_range + 1;
            end
        end
        if NdPhMax_in_search_range > 0
            disp('dPh-max was found in_or_near the bipolar rPw -> NG.');
            continue   % → 次の iJ loop に移る
        end
    end

    % ***Line02***
    % この行に達した events の中から、
    %     (a) rPwMax〜rPwMin 範囲内に dPhMin (位相差の極小値) が1つだけ存在する、
    %  AND
    %     (b) その dPhMin が以下のどちらかを満たす：
    %         (b1) datNos_search_sttB〜datNos_search_endB の範囲内に
    %              他の dPhMin が存在しない、
    %       OR
    %         (b2) datNos_search_sttB〜datNos_search_endB の範囲内に
    %              他の dPhMin's が存在する場合、それらより
    %              (a)の dPhMin が小さい、
    % という条件を満たす events を探す。

    N_sandwiched_dPhMin=0;
    for ja = 1:N_pks_dPhMin
        if ((IDed_datNos_dPhMin(ja) > IDed_datNos_rPwMax(iJ))  && ...
            (IDed_datNos_dPhMin(ja) < IDed_datNos_rPwMin(ik)))
            jb = ja;
            N_sandwiched_dPhMin = N_sandwiched_dPhMin + 1;
        end
    end

    if N_sandwiched_dPhMin ‾= 1
        disp('No dPh-min, or more-than-one dPh-mins, were found between the bipolar rPw -> NG.');
        continue   % → 次の iJ loop に移る
    end

    % この行に到達した = (a)「その範囲内に位相差の極小点が1つだけ存在」し、その data番号は jb。

    fprintf('The %d-th dPh-min only is between the bipolar rPw.¥n',jb);

    % 次、(b)「datNos_search_sttB〜datNos_search_endB の範囲内にある他の dPhMin's ((b1)も含む)より
    %          (a)の dPhMin が小さい」の check：
    jb_significant = 1;
    for jc = 1:N_pks_dPhMin
        if     (IDed_datNos_dPhMin(jc) < datNos_search_sttB)
            continue   % Search 範囲に達していないので、次の jc loop の次の jc に移る
        elseif (IDed_datNos_dPhMin(jc) > datNos_search_endB)
            break   % Search 範囲を出たので、jc loop を出る。
        end

        if (jc ‾= jb)
            fprintf(['The %d-th dPh-min is between datNos_search_sttB and _endB.¥n'],jc);

            if (pks_dPhMin(jc) > pks_dPhMin(jb)) % jc=1, jc=N_pks_dPhMin も含みうるが、edgeの例外処理 は必要ない。
                disp('That dPh-min is larger than the central dPh-min: OK.');
                continue  % (b) を満たしている dPhMin なので、次の jc loop に移る
            else
                disp('That dPh-min is smaller than the central dPh-min -> NG.');
                jb_significant = 0;  % (b) を満たさない dPhMin が見つかったので、NG mark を付けて、jc loop を出る。
                break
            end
        end
    end

    % この行において jb_significant=1 なら、(b)は満たされた＝全ての要求を満たした event が見つかった 事になる。
    if (jb_significant == 1)
        % disp('A new event has just been found');
        Nevents = Nevents+1
        Ev_datNos(Nevents,:) = [IDed_datNos_rPwMax(iJ), ...
                                IDed_datNos_dPhMin(jb), ...
                                IDed_datNos_rPwMin(ik)]
        continue   % → 次の iJ loop に移る
    end
end

if Nevents == 0
    disp('No event was identified.');
    Ev_datNos = NaN;
else
    Nevents
    Ev_datNos
end
