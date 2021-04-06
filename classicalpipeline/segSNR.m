function [struct] = segSNR(struct,peaks)
% This function calclulates the SNR of the protein bands identifeid by segmentation.
%% Inputs:
%% - struct: the MATLAB structure file containing the array
%% - peaks: number of protein bands for which the user wishes to calculate SNR values
%% 
%% Outputs:
%% - struct.segmented_SNR: an array containing the [mean, noise, SNR] for each protein band in
%%                         each separation lane. Dimension n x 3 x j, where n is the number of
%%                         separation lanes, and j is the number of protein bands per lane. 
%% - struct.good_snr_indices_segmentation: A list of indices where ALL protein bands in that
%%                                         separation lane have an SNR >= 3. 

    % segmented_SNR returns [mean, noise, SNR]
    struct.segmented_SNR = zeros(length(struct.rois),3,peaks);
    
    for j  = 1:peaks
	    for i = 1:length(struct.rois)
	        [mean,std,snr] = segSNRDevice(struct,i,j);
	        struct.segmented_SNR(i,:,j) = [mean,std,snr];
	    end
    end

    indices = 1:length(struct.rois);
    good_snr_indices = all(struct.segmented_SNR(:,3,:)>=3,3);

    struct.good_snr_indices_segmentation = indices(good_snr_indices);
end
	  
