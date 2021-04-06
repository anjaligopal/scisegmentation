function [segmented_mean,noise,SNR] = segSNRdevice(struct,i,j)
% Calculates the SNR of a given protein band (j) in a given separation lane (i)
% that is defined in 'struct'.
    
    segmented_mean = struct.segmented_AUC(i,j)/struct.areas(i,j);
    
    noise = struct.background_noise(i);
    
    SNR = segmented_mean/noise;

    if isnan(SNR)
    	SNR = 0;
  	end

end