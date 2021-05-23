%% markCropBox
% video annotation GUI built on top of movieAnalyser


classdef markCropBox < movieAnalyser

	properties
		folder_name
		mask
	end % end properties

	methods

		function a = createGUI(a)
			createGUI@movieAnalyser(a);

			p = a.handles.pause_button.Position;
			a.handles.mark_roi_button = uicontrol(a.handles.fig,'Units',a.handles.next_button.Units,'Position',p,'Style','pushbutton','String','Mark Crop','Callback',@a.markCrop);

			delete(a.handles.next_button); %.Position;
			delete(a.handles.prev_button);
			delete(a.handles.pause_button);
			delete(a.handles.scrubber);

			allfiles = dir([a.folder_name   oss '*.jpg']);
			rgb = imread([a.folder_name oss allfiles(1).name]);

			% load the first file. 
			a.handles.im.CData = rgb;

		end % end create GUI

		function a = markCrop(a,~,~)
			h = imrect(a.handles.ax);
        	crop_box = wait(h);
        	a.mask = createMask(h);
        	%a.handles.fig.Name = ('Crop box saved! Close this window to continue.');
       
		end




	end % end methods
end