function [struct] = segProcess(struct,disksize,peaks,min_area,max_circularity,thresh_range,dist_thresh,dilate_size)
% This function takes a MATLAB structure with roi_post_bgsubtract as input and performs thresholding of an 
% ROI based on Otsu's method, segmentation based on the Watershed transform, 
% selection of peaks in the specified 'centroid_range', that are greater than 'min_area' 
% and smaller than 'max_circularity'. 

% Inputs:
% - struct: the structure file (that should have been created with segBackground.m)
% - disksize: the size of the structural disk element used for morphological image processing
%             (recommended size: between 3 - 5 px)
% - peaks: number of protein bands you wish to detect in your separation lane
% - min area: the minimum area of your protein bands; recommended 125 px
% - max circularity: the maximum circularity of your protein band (closer to ~1 is more circular)
%                    recommended value: < 1.5
% - thresh range: which "fractional thresholds" of Otsu's initial thresholds you want to try.
%                 If you only want to use Otsu's threshold, set thresh_range = 1.
%                 For noisy separation lanes, try [1:-0.1:0.1]
% - dist_thresh: distance threshold used for the distance transform. 
%                recommended value: 0.35
% - dilate_size: the size of the structural disk element used for the final image dilation
%                  (recommended size: 5 px)

% Outputs:
% - Returns a MATLAB structure with the segmented regions, segmented labels, threshold values, 
% areas, circularities, and AFU of the protein bands in a given separation lane. 
% Note: "segmented_full" is the initial segmented separation lane, whereas segmented_labels
% only contains the labels of the regions that passed QC. 

%% Segmentation

    %% Getting the centroid range

    centroid_range = struct.centroid_range;

    % Getting the size of the ROIs
    [roi_x,roi_y,roi_z] = size(struct.rois); 

    % creating arrays to store outputs 
    circularities_array = zeros(roi_z,peaks);
    area_array = zeros(roi_z,peaks);
    segmented_region = zeros(roi_x,roi_y,roi_z);
    segmented_AUC = zeros(roi_z,peaks);
    segmented_labels = zeros(roi_x,roi_y,roi_z);
    segmented_full = zeros(roi_x,roi_y,roi_z);
    otsu_threshold = zeros(roi_z,1);

    % Setting the 'thresh_range' variable correctly 
    % If it progressively goes down and finds nothing,
    % then set the last one to 1

    if length(thresh_range) > 1
        thresh_range(length(thresh_range)) = 1; 
    end

    % Looping through segmentation thresholds

    for i = 1:roi_z
        stopping_criterion = 0;
        kk = 1; 

        while stopping_criterion == 0 && kk <= length(thresh_range)

            thresh_level = thresh_range(kk);

    		img = uint16(struct.rois_post_bgsubtract(:,:,i));

            % segmentRegion.m performs the segmentation task on each separation lane 
            segmented_device = segmentRegion(img,disksize,thresh_level,dist_thresh,dilate_size); 
            
            measurements = regionprops(segmented_device,'Centroid','Area','Perimeter'); 

            % watershedSelect.m performs the quality control check 
            [peak_no,peak_img,peak_circularities,peak_areas] = watershedSelect(segmented_device,measurements,centroid_range,peaks,min_area,max_circularity);
            
            selected_peaks = sum(peak_no > 0); % How many good peaks were found?

            if sum(selected_peaks) == peaks
                stopping_criterion = 1;
            end

            kk = kk+1; 

        end

        otsu_threshold(i) = thresh_level;

        % Calculating analysis parameters

        circularities_array(i,:) = peak_circularities;
        area_array(i,:) = peak_areas;
        segmented_region(:,:,i) = sum(peak_img,3);
                
        % Calculating segmented AUC

        segmented_labels_for_current_roi = zeros(roi_x,roi_y);

        for j = 1:peaks
            segmented_image = peak_img(:,:,j).*double(img);
            segmented_AUC(i,j) = sum(sum(segmented_image));

            segmented_labels_for_current_roi = segmented_labels_for_current_roi + j.*peak_img(:,:,j);
        end        

        segmented_labels(:,:,i) = segmented_labels_for_current_roi;

        segmented_full(:,:,i) = segmented_device; 
    end

    % % Assigning outputs in the structure file. 
    struct.circularities = circularities_array;
    struct.segmented_AUC = segmented_AUC;
    struct.areas = area_array; 
    struct.segmented_region = segmented_region; 
    struct.segmented_labels = segmented_labels; 
    struct.segmented_full = segmented_full;
    struct.otsu_threshold = otsu_threshold;
end
