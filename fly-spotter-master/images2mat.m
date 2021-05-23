%% images2mat.m
% combines a set of images to a giant 3D matrix
% 
function [images, full_images] = images2mat(path_name,mask,varargin)


% options and defaults
options.channel = 3;
options.subtract_median = true;

if nargout && ~nargin 
	varargout{1} = options;
    return
end

% validate and accept options
if iseven(length(varargin))
	for ii = 1:2:length(varargin)-1
	temp = varargin{ii};
    if ischar(temp)
    	if ~any(find(strcmp(temp,fieldnames(options))))
    		disp(['Unknown option: ' temp])
    		disp('The allowed options are:')
    		disp(fieldnames(options))
    		error('UNKNOWN OPTION')
    	else
    		options = setfield(options,temp,varargin{ii+1});
    	end
    end
end
elseif isstruct(varargin{1})
	% should be OK...
	options = varargin{1};
else
	error('Inputs need to be name value pairs')
end

% find all *JPG images
allfiles = dir([path_name oss '*.JPG']);

assert(~isempty(allfiles),'No JPG images found!')

% read the first image
rgb = imread([path_name oss allfiles(1).name]);

if isempty(mask)
	% load the first one to get the size right
	mask = true(size(rgb,1),size(rgb,2));
else
	rgb = mask;
end

% convert mask into crop box
crop_x = any(mask,2);
crop_y = any(mask,1);
cropped_image = rgb(crop_x,crop_y,:);

images = zeros(size(cropped_image,1),size(cropped_image,2),length(allfiles),'uint8');
full_images = zeros(size(cropped_image,1),size(cropped_image,2),3,length(allfiles),'uint8');

for i = 1:length(allfiles)
	textbar(i,length(allfiles))
	rgb = imread([path_name oss allfiles(i).name]);
	images(:,:,i) = 255 - rgb(crop_x,crop_y,options.channel);
	full_images(:,:,:,i) = rgb(crop_x,crop_y,:);
end

if options.subtract_median
	% subtract the median from all the images
	median_image = median(images,3);
	for i = 1:size(images,3)
		images(:,:,i) = images(:,:,i) - median_image;
	end
end





