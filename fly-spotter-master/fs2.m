% fly-spotter
% 
% created by Srinivas Gorur-Shandilya at 1:53 , 21 December 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function [r,rgb] = fs2(rgb)

I = rgb2gray(rgb);
bottom_bit = floor(.8*size(rgb,1));

% since flies are dark, flip the image around
I = 255-I;

% find the cylinder edges
Ic = I;
se = strel('disk', 5);
Ic = imerode(Ic, se);
Ic = im2bw(imadjust(Ic));
Ic(bottom_bit:end,:)= 0;
r = regionprops(bwlabel(Ic),'Orientation','Area');
temp = sort([r.Area]);
r([r.Area] < temp(end-1)) = [];
if r(1).Orientation > 0
	I = imrotate(I,90-r(1).Orientation,'bicubic','crop');
else
	I = imrotate(I,270-r(1).Orientation,'bicubic','crop');
end


% make a mask where the walls of the cylinder, and other large bits of junk are
se = strel('line', 50,90);
Ie = imerode(I, se);
Ie = im2bw(imadjust(Ie));
Ie = imdilate(Ie,strel('disk',10));
Ie = imdilate(Ie,strel('line',50,90));

% make sure the mask extends all the way to the bottom
mask_sum = sum(Ie);

Ie(bottom_bit:end,mask_sum>max(mask_sum)/2) = 1;

% mask 
I(Ie) = 0;
I = im2bw(I);

% find particles
L = bwlabel(I);
r0 = regionprops(L,'Area','Centroid');
r = r0;


% throw out very small regions
r([r.Area]<40) = [];

resolve_these = find([r.Area]>1.5*mean([r.Area]));
for i = 1:length(resolve_these)
	resolve_this = resolve_these(i);
	% blank out everything else
	ff = L;
	ff(ff~=resolve_this) = 0;
	ff(ff~=0) = 1;
	ff = cutImage(ff',r0(resolve_this).Centroid,50);

	% keep opening the image till iwe split the object
	for s = 1:20
		ff_open = imopen(ff,strel('disk',s,0));
		rr =  (regionprops(logical(ff_open),'Centroid','Area'));
		if length(rr) > 1

			break
		end
	end

	if length(rr) == 0
		% plot(r(i).Centroid(1),r(i).Centroid(2),'r+','MarkerSize',12)
	else
		for j = 1:length(rr)
			rr(j).Centroid(1) = rr(j).Centroid(1) + r(resolve_this).Centroid(1) - 50 ;
			rr(j).Centroid(2) = rr(j).Centroid(2) + r(resolve_this).Centroid(2) - 50;
		end
		r(resolve_this) = [];
		r = [r; rr];
	end
end

