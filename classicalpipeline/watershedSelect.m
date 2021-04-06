function [peak_indices,peak_img,peak_circularities,peak_areas] = watershedSelect(img,measurements,centroid_range,peaks,min_area,max_circularity)
%% This function selects the best segments from a given image.
% INPUTS:
% - img: the segmented file
% - measurements: list of measurements of each segment
% - centroid_range: the area where the centroid should be
% - peaks: the number of protein bands of peaks to segment
% - min_area: the min area (for all peaks)
% - max_circularity: the max circularity (for all peaks)


    % Getting all of the different parameters
    area = [measurements.Area];
    perimeter = [measurements.Perimeter];
    circularities = perimeter.^2 ./ (4.*pi.*area);
    no_of_regions = length(area); 
    centroids = reshape([measurements.Centroid],2,no_of_regions)'; % weird reshaping because of how this works
    [img_x, img_y] = size(img);

    % Outputs
    peak_indices = zeros(peaks,1);
    peak_img = zeros(img_x,img_y,peaks);
    peak_circularities = zeros(peaks,1);
    peak_areas = zeros(peaks,1);

    for i = 1:peaks

        peak_data = table([1:length(area)]',area',circularities',centroids(:,1),centroids(:,2));
        peak_data.Properties.VariableNames = {'Peak','Area','Circularity','Centroid_X','Centroid_Y'};

        % STEP 0: Filter out peaks that have already been selected

        if i > 1
            selected_indices = nonzeros(unique(peak_indices));

            % disp(selected_indices)

            for jj = 1:length(selected_indices)
                peak_data = peak_data(peak_data.Peak ~= selected_indices(jj),:);
            end
        end

        % STEP 1: Search the centroids array to find one that matches
        % the range specified by the user. 

        peak_data = peak_data(peak_data.Centroid_X > centroid_range(i,1),:);
        peak_data = peak_data(peak_data.Centroid_X < centroid_range(i,3),:);

        peak_data = peak_data(peak_data.Centroid_Y > centroid_range(i,2),:);
        peak_data = peak_data(peak_data.Centroid_Y < centroid_range(i,4),:);

        if isempty(peak_data)
            peak_index = 0;

        elseif height(peak_data) == 1
            % If there is only one region that matches, assign the index
            % to that.
            selected_peak = peak_data;
            peak_index = selected_peak.Peak;

        else

            % STEP TWO: If more than 1 that matches the centroids, then
            % filter by peaks that exceed 'min_area'. 
            
            % This is bad coding, but we need to make centroids_indices
            % change size, depending on the number of matches. 
            

            peak_data = peak_data(peak_data.Area >= min_area,:);
            
            if isempty(peak_data)
                peak_index = 0;
             
            elseif height(peak_data) == 1
                
                selected_peak = peak_data;
                peak_index = selected_peak.Peak;
                
            else
                
                % STEP THREE: If more than 1 that matches 'min_area'
                % threshold, then filter by peaks that are below
                % 'max_circularitiy'. 
                


                peak_data = peak_data(peak_data.Circularity <= max_circularity,:);

                if isempty(peak_data)
                    peak_index = 0;
                
                elseif height(peak_data) == 1
                    selected_peak = peak_data;
                    peak_index = selected_peak.Peak;
                
                else
                    
                    % STEP FOUR: If more than 1 matches for 'max_circularity',
                    % threshold, then select the peak with the largest Y-coordinate. 

                    peak_data = sortrows(peak_data,'Centroid_Y','ascend');

                    selected_peak = peak_data(1,:);
                    peak_index = selected_peak.Peak;
                end  
            end       
        end

        %% Assigning proper values at the end of the loop    
        
        peak_indices(i) = peak_index;   

        if peak_index ~= 0
            peak_areas(i) = selected_peak.Area;
            peak_circularities(i) = selected_peak.Circularity;
            peak_img(:,:,i) = (img == peak_index);
            
        else
            peak_areas(i) = 0;
            peak_circularities(i) = 0;
        end
    
    end
    
    peak_indices = peak_indices; 
end

