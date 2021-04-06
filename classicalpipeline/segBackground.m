function [struct] = segBackground(struct,backgroundWidth)
% This function takes a MATLAB structure (generated from roiGeneration.m) 
% and performs background subtraction from the gutter regions of the separation
% lanes, based on the number of pixels specified in backgroundWidth. 
% Also stores the standard deviation of the gutter regions (bg noise) for future 
% SNR calculations. 

% The following code is a derivative work of the code from Summit 
% (https://github.com/herrlabucb/summit/)which is licensed GPLv3. This code 
% therefore is also licensed under the terms of the GNU Public License, verison 3.

	% Getting the size of the ROIs
	[roi_x,roi_y,roi_z] = size(struct.rois); 

	% creating an entry to store the post-bg-subtracted ROIs
	struct.rois_post_bgsubtract = zeros(roi_x,roi_y,roi_z); 

	% creating an entry to store bg values for SNR calculations
	struct.background = zeros(roi_x,2*backgroundWidth,roi_z)
	struct.background_noise = zeros(roi_z,1);

	% Loop to perform background subtraction

	for i = 1:roi_z

		I = struct.rois(:,:,i); % ROI we want to work with

		% Calculating the average of the futter region
		left_backgroundregion=I(:,(1:backgroundWidth)); 
		right_backgroundregion=I(:,(((end+1)-backgroundWidth):end));
		left_background_int=(sum(left_backgroundregion,2))/backgroundWidth;
		right_background_int=sum(right_backgroundregion,2)/backgroundWidth;
		mean_background=(left_background_int+right_background_int)/2;

		[I_rows,I_cols] = size(I);

		% This repeats the background for the number of columns in the ROI
		background_matrix = vec2mat(repmat(mean_background,1,I_cols),roi_y);

		% Storing ROI post background subtraction
		I = I - background_matrix; 
		struct.rois_post_bgsubtract(:,:,i) = I;

		% Storing the background
		background = [left_backgroundregion,right_backgroundregion];
		struct.background(:,:,i) = background; 
		struct.background_noise(i) = std(background,1,'all');

	end
end
	  
