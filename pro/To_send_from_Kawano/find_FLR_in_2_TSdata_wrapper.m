function find_FLR_in_2_TSdata_wrapper(rPw_dPh_file,Nmovavr)
%
% 下記 Infile の存在する folder での実行を想定している。

NmovavrTxt = sprintf('%2.2d',Nmovavr)

OutFile = ['autoIDed_FLR_list.freq_movavr_by_', NmovavrTxt '.txt'];
OUT = fopen(OutFile,'wt'); % w: 既存の内容がある場合それは破棄される
                           % t: テキスト モードでファイルを開くときに追加
                           % (matlab 内の help からの情報)
                           % https://jp.mathworks.com/help/matlab/ref/fopen.html
    
InFile = ['rPw_dPh_vs_freq_movavr_by_', NmovavrTxt '.txt'];
disp(InFile);

% 念のため
clear f_rPw_dPh freq rPw dPh;

[f_rPw_dPh] = textread(InFile,'','delimiter',' ');

[nrow,ncol] = size(f_rPw_dPh);
if ncol<3
    disp 'ncol<3';
    continue;
end

freq = f_rPw_dPh(:,1);
rPw  = f_rPw_dPh(:,2);
dPh  = f_rPw_dPh(:,3);
[Nevents,Ev_datNos] = find_FLR_in_SD_dRG(rPw,dPh);

for jk=1:Nevents
Nnow_rPwMax = Ev_datNos(jk,1);
Nnow_dPhMin = Ev_datNos(jk,2);
Nnow_rPwMin = Ev_datNos(jk,3);
    
fprintf(OUT,'%3d',RG);
fprintf(OUT,'%5d%5d%5d',...
	    [	  Nnow_rPwMax	    Nnow_dPhMin	      Nnow_rPwMin ]);
fprintf(OUT,'%12.7f%12.7f%12.7f',...
	    [freq(Nnow_rPwMax) freq(Nnow_dPhMin) freq(Nnow_rPwMin)]);
fprintf(OUT,'%16.3f%16.3f%16.3f',...
	    [ rPw(Nnow_rPwMax)	rPw(Nnow_dPhMin)  rPw(Nnow_rPwMin)]);
fprintf(OUT,'%16.3f%16.3f%16.3f',...
	    [ dPh(Nnow_rPwMax)	dPh(Nnow_dPhMin)  dPh(Nnow_rPwMin)]);
fprintf(OUT,'¥n');
end

fclose(OUT);
