function [r,rgb] = fs4(afn,xxx)
if ~nargin
    afn = 'D:\QMDownload\12\DSC_0004.JPG';
    xxx.ImageCrop = [1500,50,1500,2950];
    xxx.ImageHeightPixels = 3000;
    xxx.strelShape1 = 'square';
	xxx.strelSize1 = 30;
    xxx.strelShape2 = 'disk';
	xxx.strelSize2 = 5;
    xxx.rgbWhich = 3;
	xxx.flyPixelsMin = 20;
    xxx.flyEccentricityMax = 0.985;
	xxx.flyMinorMajorAxisRatioMin = 0.2;
end
% meant to work with "vanguard images" from TWK
% created by Srinivas Gorur-Shandilya at 10:14 , 29 December 2015. Contact me at http://srinivas.gs/contact/
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
%%
rgb = imread(afn);
assert(xxx.ImageHeightPixels==size(rgb,1),['Error: image height pixels is not equal to ',num2str(xxx.ImageHeightPixels)]);
% 选蓝色channel
    I_ = 255 - rgb(:,:,xxx.rgbWhich);
% Ignoring the top and sides of the image
    I = I_ (xxx.ImageCrop(2):xxx.ImageCrop(2)+xxx.ImageCrop(4),xxx.ImageCrop(1):xxx.ImageCrop(1)+xxx.ImageCrop(3));
% Correcting uneven illumination
    % I=biasCorrection_bipoly(I);
    I = imtophat(I,strel(xxx.strelShape1,xxx.strelSize1));
% Adjusting contrast
    % I = imadjust(I);
% Thresholding image
    % Ibw = (im2bw(I,.9));
    temp = sort(I(:),'descend');
    Ibw = im2bw(I,mean(temp(1:1e3))/500);
    Ibw = imclose(Ibw,strel(xxx.strelShape2,xxx.strelSize2));
    L = bwlabel(Ibw);
%Detecting objects
    r0 = regionprops(L,I,'Area','Centroid','MaxIntensity','Orientation','Perimeter','MajorAxisLength','MinorAxisLength','Eccentricity');
    if length(r0) > 100 % a sign of something going wrong
        %挖空结构体的部分索引！哈哈有用！
        r0([r0.MaxIntensity] < max(max(I))/2) = [];end
    r = r0;disp([afn,': ',mat2str(length(r)) ' objects found.']);
% Ignoring very small objects
    small_objects = find([r.Area]<xxx.flyPixelsMin | ([r.Eccentricity]>xxx.flyEccentricityMax) | ([r.MinorAxisLength]./[r.MajorAxisLength]<xxx.flyMinorMajorAxisRatioMin)); %filter by area
    r(small_objects) = [];r0(small_objects) = [];
    for i = 1:length(small_objects);L(L==small_objects(i)) = 0;end
%% Build areas using the labelled image instead of the regionprops object
if length(r) > 2
    % 粘连果蝇判定:粘连体周长超过平均周长的1.5倍
    resolve_these = find([r.Perimeter]>1.5*mean([r.Perimeter]));
    if length(resolve_these);disp([afn,': Resolving very large objects...']);
        for i = 1:length(resolve_these)
            resolve_this = resolve_these(i);
            % blank out everything else
            ff = L;ff = cutImage(ff',r0(resolve_this).Centroid,50)';
            dominant_label = mode(nonzeros(ff(:)));
            ff(ff~=dominant_label) = 0;
            % ff(ff~=L(round(r(resolve_this).Centroid(2)),round(r(resolve_this).Centroid(1)))) = 0;
            ff(ff~=0) = 1;ok = false;% keep opening the image till we split the object
            for s = 1:20
                %% 继续通过imopen瘦身剥离粘连
                ff_open = imopen(ff,strel('disk',s,0));
                rr = (regionprops(logical(ff_open),logical(ff_open),'Centroid','Area','MaxIntensity','Orientation','Perimeter'));
                if length(rr) > 1;disp([afn,': Succesfully resolved overlapping flies...']);
                    ok = true;break;end;end
            if ~ok;disp([afn,': Automatic object deconvolution failed. Using k-means...']);
                % use k-means to split them
                temp = regionprops(ff,'PixelList');
                [idx,C] = kmeans(temp.PixelList,2);rr = r(resolve_this);
                rr(1).Centroid(1) =  C(1,1);rr(1).Centroid(2) =  C(1,2);rr(1).Area = sum(idx==1);
                rr(2).Centroid(1) =  C(2,1);rr(2).Centroid(2) =  C(2,2);rr(2).Area = sum(idx==2);
                % also inherit the orientations
                rr(1).Orientation = r0(resolve_this).Orientation;rr(2).Orientation = r0(resolve_this).Orientation;end
            if length(rr) ~= 0;for j = 1:length(rr)
                    rr(j).Centroid(1) = rr(j).Centroid(1) + r(resolve_this).Centroid(1) - 50 ;
                    rr(j).Centroid(2) = rr(j).Centroid(2) + r(resolve_this).Centroid(2) - 50;
                end;r(resolve_this) = [];r = [r; rr(:)];end;end;end;end;end
