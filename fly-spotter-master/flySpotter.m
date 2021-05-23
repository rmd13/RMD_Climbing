function flySpotter(rtFolder,ImgFmt,xxx)
% fly-spotter
% spots flies in images
% created by Srinivas Gorur-Shandilya at 1:53 , 21 December 2015. Contact me at http://srinivas.gs/contact/
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
%%
IMGlist = dir([rtFolder,'\*',ImgFmt]);
if isempty(IMGlist);disp('...Warning! No images found! Returned!');return;end
yyy=xxx;
% make placeholders for positions, areas and orienatons.
% first dimensions is a dummy (for number of flies in each file, and second dimension is as long as there are files.)
all_positions = cell(1,length(IMGlist));
all_areas = cell(1,length(IMGlist));
all_orientations = cell(1,length(IMGlist));
all_names = {IMGlist.name};
if xxx.nPool>0
    RMD_secureLocalPoolOn(xxx.nPool);
    ppm  = ParforProgressStarter2('Progression ',length(IMGlist),0.1, 1, 1, 1);
    parfor i = 1 : length(IMGlist);afn = [rtFolder,'\',IMGlist(i).name];ppm.increment(1);
        [all_y,all_area,all_orientation] = RMD_flySpotter_mediator(afn,yyy);
        [all_positions{i},all_areas{i},all_orientations{i}] = deal(all_y,all_area,all_orientation);
    end;try;delete(ppm);end;else;aBar = waitbar(0,'flySpotter progress');
    for i = 1 : length(IMGlist);afn = [rtFolder,'\',IMGlist(i).name];waitbar(i/length(IMGlist),aBar)
        [all_y,all_area,all_orientation] = RMD_flySpotter_mediator(afn,yyy);
        [all_positions{i},all_areas{i},all_orientations{i}] = deal(all_y,all_area,all_orientation);
    end;try;close(aBar);end;end
%% Write sheet 1 -- Positions on Y axis
aMaxHeight = max(cellfun(@(x) length(x),all_positions));
temp = NaN(aMaxHeight,length(IMGlist));
for i = 1 : length(IMGlist);temp(1:length(all_positions{i}),i) = all_positions{i};end
temp = temp * xxx.ImageHeightCm/xxx.ImageHeightPixels;
% z = find(sum((~isnan(temp)),2) == 0,1,'first');temp = temp(1:z-1,:);
write_me = [all_names; num2cell(temp)];
cell2csv([rtFolder,'\results_positions.csv'],write_me,[],[],[],[],1);
%% Write sheet 2 -- Areas
aMaxHeight = max(cellfun(@(x) length(x),all_areas));
temp = NaN(aMaxHeight,length(IMGlist));
for i = 1 : length(IMGlist);temp(1:length(all_areas{i}),i) = all_areas{i};end
% z = find(sum((~isnan(temp)),2) == 0,1,'first');temp = temp(1:z-1,:);
write_me = [all_names; num2cell(temp)];
cell2csv([rtFolder,'\results_areas.csv'],write_me,[],[],[],[],1);
%% Write sheet 3 -- Orientations
aMaxHeight = max(cellfun(@(x) length(x),all_orientations));
temp = NaN(aMaxHeight,length(IMGlist));
for i = 1 : length(IMGlist);temp(1:length(all_orientations{i}),i) = all_orientations{i};end
% z = find(sum((~isnan(temp)),2) == 0,1,'first');temp = temp(1:z-1,:);
write_me = [all_names; num2cell(temp)];
cell2csv([rtFolder,'\results_orientations.csv'],write_me,[],[],[],[],1);
winopen(rtFolder);bird;
