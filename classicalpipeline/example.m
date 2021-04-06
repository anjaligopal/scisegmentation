% Divide the array into individual separation lanes
horzspacing = 80;
vertspacing = 200;
[struct] = roiGeneration('mcf7_btub.tif',horzspacing, vertspacing);
pause
close all

% Perform background subtraction for each separation lane
[struct] = segBackground(struct,5);

% Perform centroid selection 
struct = segCentroids(struct,1);
close all

% Peforming segmentation

disksize = 5;
min_area = 125;
max_circularity = 1.5; 
dist_thresh = 0.35;

[struct] = segProcess(struct,disksize,1,min_area,max_circularity,1,dist_thresh,3);

% Perform quality control
struct = segQC(struct,1,min_area,max_circularity);
	