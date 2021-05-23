% fs3
% 
% created by Srinivas Gorur-Shandilya at 10:04 , 22 December 2015. Contact me at http://srinivas.gs/contact/
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

function [r,rgb] = fs3(rgb)

I = rgb(:,:,1);
I = 255 - I;

% top hat filtering
I = (imtophat(I,strel('disk',5)));
Ibw = (im2bw(I,graythresh(I)));


L = bwlabel(Ibw);

r0 = regionprops(L,'Area','Centroid');
r = r0;


% throw out very small regions
r([r.Area]<10) = [];

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

