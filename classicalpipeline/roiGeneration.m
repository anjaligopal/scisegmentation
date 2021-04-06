function [struct] = roiGeneration(filename,horzspacing,vertspacing,struct)
% This function rotates and aligns a raw fluorescent image of a single-cell
% Western blot array and segments the image into regions-of-interest (ROIs)
% for downstream analysis. Each region of interest encompasses single-cell 
% Western blot protein peak(s) in an area defined by the horizontal and 
% vertical spacing between microwells in the array.

% This script was adapted from SUMMIT (https://github.com/herrlabucb/summit) under a GPL-3.0 License. 

%   Outputs:  
% Struct [structure]: A data structure containing objects:
%   struct.rois: 3D matrix with each ROI contained in a different z.
%   struct.angle: The angle of rotation to straighten the image (number, in degrees).
%   struct.rotate: The angle of rotation required to display the image with
%   separations running vertically instead of horizontally (number, in
%   degrees).
%   struct.array_bounds: User selected boundaries of the array as a 3x2
%   matrix (rows contain upper left, upper right, and lower left
%   coordinates respectively; first column contains x-coordinates; second column contains y-coordinates). 
%   struct.name: The name of the protein target entered by the user
%   (string).
%   struct.wells_per_row: The number of wells per row based on the user
%   selected array bounds and horizontal well spacing.
%   struct.rows: Number of rows in the array 

%   Inputs:
% filename [string]: A string containing the name of the fluorescence image
%                   to be processed.
% horzspacing [num]: Well-to-well spacing (horizontal, in pixels)
% vertspacing [num]: Well-to-well spacing (vertical, in pixels)
% struct [structure] (optional): A structure containing "angle" and
% "array_bounds" if the same image has already been analyzed by
% roiGeneration. The same ROIs will automatically be generated.

%% versions
% 0.1-Created April, 2016
% 0.2 (5.15.16): Updated to apply same transform for ROI generation if user
% inputs a struct with the fields "angle" and "rotate".
% 0.3 (5.20.16): Added "rows" and "wells per row" fields to structure.
% 0.4 (3.25.20): Includes red cross-hairs for identifying microwells; function
%                contributed by Samantha Grist (samantha.m.grist@gmail.com)

% Copyright 2016 Julea Vlassakis (julea.vlassakis@gmail.com) and Kevin Yamauchi (kevin.yamauchi@gmail.com)
% The following code is a derivative work of the code from Summit (https://github.com/herrlabucb/summit/)
% which is licensed GPLv3. This code therefore is also licensed under the terms 
% of the GNU Public License, verison 3.


%% Check input arguments
switch nargin
    % If the user only provides the image, horizontal and vertical spacing
    case 3
        transform = 0;
    case 4
        transform = 1;
        
        tf = isstruct(struct);
            if tf == 0
                 error('Input argument "struct" is not a structure.');
            
            return
            
            end
            
        % retrieve previously determined angle for transformation of image
        angle = struct.angle;
        
        % retrieve previously determined array boundaries
        array_bounds = struct.array_bounds;
        
        % extract the individual x an y coordinates of the array boundaries
        x_upperleftwell = array_bounds(1, 1);
        y_upperleftwell = array_bounds(1, 2);
        
        x_upperrightwell = array_bounds(2, 1);
        y_upperrightwell = array_bounds(2, 2);
        
        x_lowerrightwell = array_bounds(3, 1);
        y_lowerrightwell = array_bounds(3, 2);
        
    
    otherwise
        
        error('Invalid number of input arguments');
            
        return
        
end
%% 
% ask the user the name of their protein target
prompt = 'What is the name of your protein target?\n';
str = input(prompt, 's');
struct.name = str;


% Load the image file in MATLAB
img = imread(filename);
    
    if transform == 0
        
        % Display more contrasted image in window
        contrasted_img = histeq(img);
        imshow(contrasted_img);

        % Display a message to the user asking them to look at the array
        title('Take a look at the array and determine if the wells are oriented left of the bands or right of the bands. Then press any key');
        pause()

        % Construct a questdlg to ask the user how the image is currently oriented
        % for coarse rotation
        choice = questdlg('Are the wells currently left of the bands or right of the bands?', ...
        'Current array orientation', ...
        'Wells are left of bands','Wells are right of bands','Wells are right of bands');
       
        % Handle response
        switch choice
            
            case 'Wells are left of bands'; 
                disp(sprintf([choice '\nOkay, the image will be rotated to the right!']))
                rotate = -90;
                
            case 'Wells are right of bands';
                disp(sprintf([choice '\nOkay, the image will be rotated to the left!']))
                rotate = 90;
        end
        
        % Store the course rotation angle to orient the array vertically to
        % the struct
        
        struct.rotate = rotate;
    else
         
        rotate = struct.rotate;
    end
  
  % Display the course-rotated image
  imgrotated = imrotate(img, rotate);
  contrasted_img_r = histeq(imgrotated);
  imshow(contrasted_img_r);
  
  %If struct was not an input argument (and there is no previous
  %angle/array boundary values to draw from), the user will now manually
  %select the array boundaries.
  
while transform == 0
  test = 1;
    
    while test == 1

        % Display the course-rotated image
        imgrotated = imrotate(img, rotate);
        contrasted_img_r = histeq(imgrotated);
        imshow(contrasted_img_r);


        % Prompt user to select the upper right well of the array. 
        title('Please zoom in on the the middle of the upper left well and press any key.');
        
        % use mouse button to zoom in or out
        zoom on;   
        pause()
        zoom off;
        
        % preallocate array bounds matrix
        array_bounds = zeros(3, 2);
        
        % prompt user to click on the middle of the upper left well
        title('Please click on the middle of the upper left well.');
        
        [x_click,y_click] = ginput(1);
        
        % store the coordinates the user selected for the upper left well
        x_upperleftwell = x_click;
        y_upperleftwell = y_click;
        zoom out;
        
        array_bounds(1,:) = [x_upperleftwell, y_upperleftwell];
        

        % SG Added to draw position selected:       
        hold on;        
        upperLeftMarker = plot(x_upperleftwell,y_upperleftwell, '.r');      
        set(upperLeftMarker, 'MarkerSize', 10);     
        %rowGuideLine = line([0,size(imgrotated, 2)], [y_upperleftwell,y_upperleftwell]);       
        % End SG

        % Change message displayed in figure window to indicate the user should zoom in on the
        % upper right well
        title('Please zoom in on the middle of the upper right well and press any key.')
        
        % use mouse button to zoom in or out
        zoom on;   
        pause()
    
        zoom off;
        
        % prompt user to click on the middle of the upper right well
        title('Please click on the middle of the upper right well.');
        
        [x_click,y_click] = ginput(1);
        
        % store the coordinates of the user-selected upper right well
        x_upperrightwell = x_click;
        y_upperrightwell = y_click;
        zoom out;
        
        array_bounds(2,:) = [x_upperrightwell, y_upperrightwell];
        

        % SG Added:     
        hold on;        
        upperRightMarker = plot(x_upperrightwell,y_upperrightwell, '.r');       
        set(upperRightMarker, 'MarkerSize', 10);        
        connectLine = line([x_upperleftwell,x_upperrightwell], [y_upperleftwell,y_upperrightwell], 'Color', 'r');       
        % End SG        
                


        % Change display in imaged window to indicate user should zoom in
        % on the middle of the lower right well
        title('Please zoom in on the middle of the lower right well and press any key.')
        
        % use mouse button to zoom in or out
        zoom on;   
        pause()
        zoom off;
    
        % prompt user to click on the middle of the lower right well
        title('Please click on the middle of the lower right well.');
        
        [x_click,y_click] = ginput(1);
        
        % store the user-selected coordinates of the lower right well
        x_lowerrightwell = x_click;
        y_lowerrightwell = y_click;
        
        array_bounds(3,:) = [x_lowerrightwell, y_lowerrightwell];


        % SG Added:     
        zoom out;       
        hold on;        
        lowerRightMarker = plot(x_lowerrightwell,y_lowerrightwell, '.r');       
        set(lowerRightMarker, 'MarkerSize', 10);        
        connectLine2 = line([x_upperrightwell,x_lowerrightwell], [y_upperrightwell,y_lowerrightwell], 'Color', 'r');        
        % End SG

        
        % store all of the coordinates of the array bounds to the struct
        struct.array_bounds = array_bounds;
        
        % Construct a questdlg to ask the user if they are happy with their
         % well selection
        choice = questdlg('Are you happy with your well selections?', ...
        'Well selections for array boundaries', ...
        'Yes','No','Yes');
        
        % Handle response
        switch choice
            
            case 'Yes';

                % check whether the user selected array boundaries are correct    
                if (x_upperrightwell<x_upperleftwell || y_upperrightwell>y_lowerrightwell)        
                    test = 1;
                    
                    title('Oh no! We detected you selected the wells in the wrong order. Please try again. Press any key to continue')
                    pause()
                    close all
                else
                    test = 0;
                    disp(sprintf([choice '\nGreat, let''s keep going then!']))
                end

            case 'No';
                disp(sprintf([choice '\nThat''s okay, try again!']))
                close all
                test = 1;
        end
     
    end
  
    % store the coordinates of the direction vector that extends from the upper left well to the right most point of the array
    dir_vector1 = [x_upperrightwell,y_upperleftwell] - [x_upperleftwell,y_upperleftwell];

    % store the coordinates of the direction vector that extends from the upper left well to the upper right well 
    dir_vector2 = [x_upperrightwell,y_upperrightwell] - [x_upperleftwell,y_upperleftwell];

    % Find angle between the two direction vectors [angle in degrees]
    cosangle = dot(dir_vector1, dir_vector2) / (norm(dir_vector1) * norm(dir_vector2));
    angle = acosd(cosangle);
    
        if (y_upperrightwell<y_upperleftwell)
            angle=-angle;
        end
    
    % store the angle used to straigten the image in the struct
    struct.angle=angle;  
    transform=1;

    % Display the rotated image so the array is aligned
    b = imrotate(imgrotated, angle, 'nearest','crop');
    b_contrasted = histeq(b);
    imshow(b_contrasted);
    hold on
    sz = size(b) / 2;

    % Generate a rotation matrix to multiply by the array boundary coordinates
    % to attain the new array boundaries in the rotated image
    rotation_matrix = [cosd(-angle), -sind(-angle);sind(-angle), cosd(-angle)];

    % Multiply the rotation matrix by the upper left well coordinates
    new_upper_left = rotation_matrix * [(x_upperleftwell - (sz(2)));(y_upperleftwell - sz(1))];

    % Multiply the rotation matrix by the upper right well coordinates
    new_upper_right = rotation_matrix * [(x_upperrightwell - sz(2));(y_upperrightwell - sz(1))];

    %Multiply the rotation matrix by the lower right well coordinates
    new_lower_right = rotation_matrix * [(x_lowerrightwell - sz(2));(y_lowerrightwell - sz(1))];

    % store the new upper left x and y coordinates
    x_new_upper_left = new_upper_left(1) + sz(2);
    y_new_upper_left = new_upper_left(2) + sz(1);

    % store the new upper right x and y coordinates
    x_new_upper_right = new_upper_right(1) + sz(2);
    y_new_upper_right = new_upper_right(2) + sz(1);

    % store the new lower right x and y coordinates
    x_new_lower_right = new_lower_right(1) + sz(2);
    y_new_lower_right = new_lower_right(2) + sz(1);


    % Determine number of wells per row
    wells_per_row = round((x_new_upper_right - x_new_upper_left) / horzspacing);
    struct.wells_per_row = wells_per_row;

    % Determine number of rows
    rows = round((y_new_lower_right - y_new_upper_right) / vertspacing);
    struct.rows = rows;

    % Determine total number of wells
    total_wells = wells_per_row * rows;


    % for loop to fill in the 3D matrix with ROIs from the image (proceeds row by row of the microwell array from left to right)
    % pre-allocate 3D matrix with zeros
    mat = zeros(vertspacing, horzspacing, total_wells);

    for i = 1:rows
        for j = 1:wells_per_row
            
            % determine z-coordinate for the current ROI
            z = (wells_per_row) * (i-1)+j;
            
            % set row start and end boundaries 
            row_start = (round(x_new_upper_left) - horzspacing/2) + ((j-1)*horzspacing);
            row_end = row_start + horzspacing;
            
            % set column start and end boundaries
            col_start = (round(y_new_upper_left) + ((i-1)*vertspacing));
            col_end = col_start + vertspacing;
            
            %generate lines that span the x and y coordinates of all the ROIs
            %to overlay over image to show the ROIs
            x = row_start:1:(row_end - 1);
            y = repmat(col_start, 1, length(x));
            y2 = col_start:1:(col_end - 1);
            x2 = repmat((row_end-1), 1, length(y2));
            
            % fill the matrix with the image pixels within the current ROI
            % boundaries
            mat(: ,: ,z) = b(col_start:(col_end - 1), row_start:(row_end - 1));
            
            % plot the ROI grid overlay on the image               
            plot(x', y', 'Color', 'r', 'LineStyle','-');
            plot(x', y', 'Color', 'r', 'LineStyle',':');
            plot(x2', y2', 'Color', 'r', 'LineStyle','-');
            plot(x2', y2', 'Color', 'r', 'LineStyle',':');
        end 
    end
    title('Final generated ROIs')

    % store the 3D matrix of ROIs to the struct
    struct.rois = mat;
    

end


end

