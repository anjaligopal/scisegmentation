function [struct] = segQC(struct,peaks,min_area,max_circularity) 
% segQC.m 
% This function performs quality control of segmented ROIs based on the following metrics:
% - peaks: number of protein bands you wish to detect in your separation lane
% - min area: the minimum area of your protein bands; recommended 125 px
% - max circularity: the maximum circularity of your protein band (closer to ~1 is more circular)
%                    recommended value: < 1.5
% This function returns a structure file, with good_segmented_indices as its output.

% The following code is a derivative work of the code from Summit 
% (https://github.com/herrlabucb/summit/)which is licensed GPLv3. This code 
% therefore is also licensed under the terms of the GNU Public License, verison 3.


	%%%% STEP 1: CALCULATING SNR %%%%
	% Only separation lanes with all bands having SNR > 3 will be considered.
	struct = segSNR(struct,peaks);


	%%%% STEP 2: INITIAL FILTERING %%%%

	% Getting information about ROIs
	[roi_x,roi_y,roi_z] = size(struct.rois);

	% Getting the SNR of all peaks
	segmented_snr = struct.segmented_SNR(:,3,:);

	initial_filtered_peaks = find(min(struct.areas,[],2) > min_area & max(struct.circularities,[],2) < max_circularity & min(segmented_snr,[],3) > 3.0);

	% Getting the indices of initial_filtered_peaks
	initial_filtered_peaks_index = zeros(1,roi_z);
	initial_filtered_peaks_index(initial_filtered_peaks) = 1;


	%%%% STEP 3: GUI FOR DISPLAYING INITIAL FILTERED PEAKS %%%%

	% Set number of rows/columns of subplots to display in each figure window
	n=5;
	num_subplots=n*n;

	plots_display=length(initial_filtered_peaks);
	good_devices=ones(length(initial_filtered_peaks),1);
	number_subplots=ceil(plots_display/(n*n));

	good_subplots = ones(plots_display,1);

	disp(number_subplots);

	
	z = 1; % To track the number of separation lanes displayed 
	h1 = 1; % SG modifications to retain figure position
	h2 = 2; % SG modifications to retain figure position

	%% Loop to generate subplots for user inspection of the intensity profiles

	for i=1:number_subplots
	    
	    %SG modified
	    disp(['Showing #', num2str(i), ' of ', num2str(number_subplots), ' pages of plots']);
	    
	    h1=figure(h1); % SG modifications to retain figure position
	    if i==1
	        pos = [700, 100, 600, 600];
	    else
	        pos = get(h1, 'Position');
	    end
	    set(h1, 'Position', pos);
	    % end SG modifications

	    if i==1
	        if (length(initial_filtered_peaks) > (n*n))
	          devices_subplot=(1:(n*n));
	        else
	          devices_subplot=(1:length(initial_filtered_peaks));
	        end
	    elseif i*n*n<=plots_display
	        devices_subplot=((i*n*n)-(n*n)+1):((i*n*n));
	    else 
	        devices_subplot=((i*n*n)-(n*n)):(plots_display);
	    end

		for j=1:length(devices_subplot)
	             
	            dev_number=devices_subplot(j);
	            device=initial_filtered_peaks(dev_number);

	            % disp(device);

	            figure(h1)
	            subplot(n, n, j);

				%% getting the images
				bad_band = zeros(roi_x,roi_y,3);
				bad_band(:,:,1) = struct.segmented_region(:,:,device);

				good_band = zeros(roi_x,roi_y,3);
				good_band(:,:,2) = struct.segmented_region(:,:,device);

				hold on
				imshow(struct.rois_post_bgsubtract(:,:,device))
				hold on

				%% getting segmentation masks
				gimage = image(label2rgb(struct.segmented_labels(:,:,device),'jet',[.5 .5 .5]));
				gimage.AlphaData = 0.5;   
				himage = imshow(bad_band);
				himage.AlphaData = 0;
				set(himage,'ButtonDownFcn',{@clickfnc,device})

	            hold off
	    end

	    for j=1:length(devices_subplot)

            dev_number=devices_subplot(j);
            device=initial_filtered_peaks(dev_number);

	        h2 = figure(h2);

	        if i==1
	            pos = [100, 100, 600, 600];
	        else
	            pos = get(h2, 'Position');
	        end
	        set(h2, 'Position', pos);

            subplot(n, n, j);

			hold on
			imshow(histeq(uint16(struct.rois(:,:,device))))
            title(device)
            
	        if z < plots_display
	            z = z + 1;
    		end
	    end

	    next=0;
	    figure(h1)
	    btn = uicontrol('Style', 'pushbutton', 'String', 'Next',...
	        'Position', [500 15 50 30],...
	        'Callback',@continueButton);

	    while next==0   

	        pause(0.01);
	    end
	    
	    clf(h1)
	    clf(h2)
	    
	end 

	struct.good_rois_segmentation = find(initial_filtered_peaks_index == 1)';
	struct.good_snr_indices_segmentation = find(initial_filtered_peaks_index == 1)';

end

function clickfnc(line_handle, event, device)

  initial_filtered_peaks_index = evalin('caller', 'initial_filtered_peaks_index');
  starting_opacity = get(line_handle,'AlphaData');

  if (starting_opacity == 0)
	set(line_handle,'AlphaData',0.8)
	initial_filtered_peaks_index(device) = 0;
  else
  	set(line_handle,'AlphaData',0)
  	initial_filtered_peaks_index(device) = 1; 
  end

  disp(device)

  assignin('caller', 'initial_filtered_peaks_index', initial_filtered_peaks_index);

end

function [next]=continueButton(qstring,title,str1,str2,default)
	%UNTITLED5 Summary of this function goes here
	qstring='Are you done selecting devices to throw out?';
	title='Device Quality Control';
	str1='Yes';
	str2='No';
	default='Yes';
	choice = questdlg(qstring,title,str1,str2,default);
	                % Handle response
	                    switch choice
	                        case 'Yes';
	                            disp([choice 'Great, let''s keep going then!'])
	                            next=1;
	                        case 'No';
	                            disp([choice 'Okay, please finish selecting devices to throw out'])
	                            next=0;
	                    end
	                    
	assignin('caller', 'next', next);

end
