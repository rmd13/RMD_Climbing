function RMD_Climbing(cfg)
% winopen(which_('RMD_Climbing.config'))
if~nargin;cfg = which_('RMD_Climbing.config');end;
eval(getCodeFromTextFile(cfg));
%% ִ��ͼƬ����
flySpotter(rtFolder,ImgFmt,xxx);
%% ��������
aCsvPath = [rtFolder,'\','results_positions.csv'];
if ~exist(aCsvPath,'file');disp(['---Warning! invalid file:[',aCsvPath,']']);return;end
aPosCell = csv2cell(aCsvPath);aVarAss = {};
for iTray = 1 : size(GtpsImgAss_Ass,1)
    GtpsImgAss  = GtpsImgAss_Ass{iTray,2};
    %% Ԥ������
    aIndivCell = {};aIndivCell(1,:) = GtpsImgAss(:,1)';
    aAverCell = {};aAverCell(1,:) = GtpsImgAss(:,1)';
    for iGtp = 1 : size(GtpsImgAss,1)
        % ������ǰGtp��ͼƬ���Ƽ���
        aGtpImgAss = arrayfun(@(x) [aPreTag,num2str(x,['%.',num2str(aLen),'d']),aPostTag], GtpsImgAss{iGtp,2},'uni',0);
        % ӳ�䵽aPosCell��
        aGrpHitsBool = cellfun(@(x) ismember(x,aGtpImgAss),aPosCell(1,:));
        aGrpHits = find(aGrpHitsBool);aTempCell = {};
        for iIMG = 1 : length(aGrpHits)
            if isempty(aTempCell);aTempCell = aPosCell(2:end,aGrpHits(iIMG));
            else;aTempCell(size(aTempCell,1)+1:size(aTempCell,1)+size(aPosCell,1)-1) = aPosCell(2:end,aGrpHits(iIMG));
            end %TempCell = [aTempCell;aPosCell(2:end,aGrpHits(iIMG))];
            if isequal(killNaNAsk,'Yes')% ��䲻�ܿ�������״�������,���������cell���Ի�.����arginΪemptyʱά��ԭ������.��������������ǵ���cell
                aTempCell(cellfun(@(x) isequal(x,'NaN'),aTempCell)) = [];
            else;aTempCell(cellfun(@(x) isequal(x,'NaN'),aTempCell)) = {[]};end
            % ---Ѱ��individual���ӵ���
            if isequal(killNaNAsk,'Yes');aBottomL = find(~cellfun(@(x) isempty(x),aIndivCell(:,iGtp)),1,'last');% �޳�NaN����޷��ܦ
            else;aBottomL = 1 + (iIMG-1)*(size(aPosCell,1)-1);end % ����NaN�Ķ�ܦ,������ʽ
            % individual�������������
            aIndivCell(aBottomL+1:aBottomL+length(aTempCell),iGtp) = aTempCell;
            % ---Ѱ��average���ӵ���
            aBottomR = find(~cellfun(@(x) isempty(x),aAverCell(:,iGtp)),1,'last');
            % ����average: ע��,cell2mat�Զ�������յĵ�Ԫ��
            aAverCell{aBottomR+1,iGtp} = mean(cell2mat(aTempCell));
        end;end
    %% ���csv
    cell2csv([rtFolder,'\',GtpsImgAss_Ass{iTray,1},'[Individual][ForGpd].csv'],aIndivCell);
    cell2csv([rtFolder,'\',GtpsImgAss_Ass{iTray,1},'[Average][ForGpd].csv'],aAverCell);
    %% ׼��pzfx��argin
    aVarAss(2*iTray-1:2*iTray,[1,2]) ={...
        [GtpsImgAss_Ass{iTray,1},'-Individual'],...
        [aIndivCell(1,:);cellfun(@cell2mat,arrayfun(@(x) slice_(aIndivCell(2:end,x),~cellfun(@isempty,aIndivCell(2:end,x))),[1:size(aIndivCell,2)],'uni',0),'uni',0)];
        [GtpsImgAss_Ass{iTray,1},'-Average'],...
        [aAverCell(1,:);cellfun(@cell2mat,arrayfun(@(x) slice_(aAverCell(2:end,x),~cellfun(@isempty,aAverCell(2:end,x))),[1:size(aAverCell,2)],'uni',0),'uni',0)];
        };end
 %% ���pzfx
     aPzfxtemplate = which_('_Analyze-20180630142451-v2-aA.12-BigChar-drop3-uniGre_WesternBlot.pzfx');
     aPzfxOut = [rtFolder,'\',pathTail(rtFolder),'[Individual+Average].pzfx'];
     RMD_cell_to_1Way2WayPzfx(aVarAss,aPzfxtemplate,aPzfxOut);
%% ���
% if 0;RMD_autoLabelPzfxMediator(aPzfxOut,'*Way',{},{});end
end