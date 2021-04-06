function [segmented_device] = segmentRegion(img,disksize,thresh_level,dist_thresh,dilate_size)

% This function performs the segmentation task on a separation lane, including the watershed
% transform. It should primarily be called through segProcess.m

% Inputs:
% - img: the background-subtracted ROI
% - disksize: the size of the structural disk element used for morphological image processing
%             (recommended size: between 3 - 5 px)
% - thresh_level: the "fractional thresholds" of Otsu's initial thresholds you want to try. 
%                 If set to 1, uses Otsu's threshold. 
% - dist_thresh: distance threshold used for the distance transform. 
%                recommended value: 0.35
% - dilate_size: the size of the structural disk element used for the final image dilation
%                  (recommended size: 5 px)


    % First performing median filtering (without median-filtering, we 
    % get poorer segmentation)
    device = medfilt2(uint16(img));

    % Performing thresholding based on Otsu's method
    level = double(graythresh(device))*thresh_level;

    % Binarizing the image
    device = imbinarize(device,level);

    % Creating a structural disk element
    se = strel('disk',disksize);
    
    % Performing a morphological open 
    device = imopen(device,se);
    
    % Performing a morphological close
    device = imclose(device,se);
    
    % Performing a dilation using a disk size specified by the user
    % Usually 3. 
    device = imdilate(device,strel('disk',dilate_size));
    
    device = bwareafilt(device,[5 inf]);
    
    % Calculating Euclidean distances between segments
    D = bwdist(~device);

    % Calculating image with distance transform
    if dist_thresh < 1
        dist_image = D > max(max(D))*dist_thresh;
    else
        dist_image = D;
    end

    % Performing watershed transform; MATLAB makes us do this on the
    % negative of the distance transform
    segmented_device = watershed(-dist_image);
    segmented_device(~device) = -inf;

end