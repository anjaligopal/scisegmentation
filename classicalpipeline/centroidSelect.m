function struct = centroidSelect(struct,peaks)

	average_rois = mean(struct.rois,3);

	imshow(histeq(uint16(average_rois)));

	centroid_range = zeros(peaks,4);

	colorstring = 'bgrymckbg';

	for i = 1:peaks

		title("Select and double click on centroid range for peak " + string(i))

		rect = imrect();

        centroid_range(i,:) = wait(rect); % Getting coordinates for signal1
        disp('Signal 1')

        % Once the first area is selected, do not resize it
        setResizable(rect,false); 
        setColor(rect,colorstring(i))

    end

    % Converting this from coord/size to coord/coord
    centroid_range(:,3) = centroid_range(:,1) + centroid_range(:,3)
    centroid_range(:,4) = centroid_range(:,2) + centroid_range(:,4)

    struct.centroid_range = centroid_range; 

end