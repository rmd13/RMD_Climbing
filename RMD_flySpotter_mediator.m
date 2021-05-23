function [all_y,all_area,all_orientation] = RMD_flySpotter_mediator(afn,xxx)
%%
%  all_names = [all_names IMGlist(i).name];
%  if length(fopen('all'))>100;disp('Flushing all open files...')fclose('all');end
try;[r,rgb] = fs4(afn,xxx);
    all_y = [];all_area = [];all_orientation = [];
    % 绘制图谱
    f = figure('Name',pathTail(afn),'NumberTitle','off','visible','off'); hold on;
    imagesc(rgb), axis image, axis ij
    for j = 1:length(r)
        plot(r(j).Centroid(1)+xxx.ImageCrop(1),r(j).Centroid(2)+xxx.ImageCrop(2),'ro','MarkerSize',10)
        all_y = [all_y,r(j).Centroid(2)];
        all_area = [all_area,r(j).Area];
        all_orientation = [all_orientation,r(j).Orientation];
    end;saveas(f,[dotTrunk(afn),'_results.png']);% close all
    % find distances from bottom
    all_y = size(rgb,1) - round(all_y);
    % add to database
    %         for idx = 1 : length(all_y)
    %             all_positions(idx,i) = all_y(idx);
    %             all_areas(idx,i) = all_area(idx);
    %             all_orientations(idx,i) = all_orientation(idx);
    %         end
    % 下列无法在parfor中运行,因为角标不是直白式的
    %         all_positions(1:length(all_y),i) = all_y;
    %         all_areas(1:length(all_y),i) = all_area;
    %         all_orientations(1:length(all_y),i) = all_orientation;
catch me;disp('Something went wrong with this file.');getReport(me)
end;
end