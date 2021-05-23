%% batchSpot
% fast, batch-based particle spotter
% batchSpot spots particles in a batch of images
% it assumes that noise, background, etc. are the same in
% all images, and uses this to subtract backgrounds and find objects
% usage:
% batchSpot

function [] = batchSpot(varargin)


% get options from dependencies 
options = getOptionsFromDeps(mfilename);

% defaults
options.min_size = 10;
options.x_scale = 1;
options.y_scale = 1;
options.threshold = 100;

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

p = uigetdir(pwd,'Choose folder with JPG images');
if ~p
	disp('No folder chosen, quitting')
	return
end
allfiles = dir([p oss '*.JPG']);

% make a movie analyser GUI to get a crop box
m = markCropBox;
m.folder_name =  p;
m.createGUI;

uiwait(m.handles.fig)

m.quitMovieAnalyser;
drawnow

% % convert images to matrix
[images,full_images] = images2mat(p,m.mask,options);

% find all the flies, etc. 
all_objects = struct;

tic;
for i = 1:size(images,3)
    I = images(:,:,i);
    I = I>options.threshold*mean(I(:));
    r = regionprops(I,'Area','Orientation','Centroid');
    r([r.Area]<options.min_size) = [];
    all_objects(i).r = r;
end
t = toc;
disp(['Finished analyzing ' oval(size(images,3)) 'images in ' oval(t) 'sec'])

v = verifyFlyPositions;
v.original_file_names = {allfiles.name};
v.parent_dir = p;
v.x_scale = 1;
v.y_scale  = 1;
v.nframes = length(all_objects);
v.all_objects = all_objects;
v.full_images = full_images;
v.createGUI;


