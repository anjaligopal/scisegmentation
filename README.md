# Segmentation-Based Analysis of Single-cell Immunoblots
This repository provides analysis scripts and raw images to reproduce the analysis in Gopal & Herr, "Segmentation-Based Analysis of Single-cell Immunoblots", *in preparation*. We provide two sets of code:

- **Classical segmentation pipeline**: This pipeline uses conventional thresholding (Otsu's Method) and the Watershed transform to segment single-cell immunoblots (scI). It is implemented in MATLAB.
- **Deep learning analysis**: We offer code that demonstrates training and testing of scI separation lanes through a modified AlexNet model for classification of protein bands, and a modified U-Net model for segmentation of protein bands.

## Installation

### Classical Pipeline
To download and use the scI segmentation pipeline, please ensure you have MATLAB 2018b or greater installed, as well as the **Image Processing Toolbox**.

Next, please download the classicalpipeline/ folder and add that to your MATLAB path (via command `addpath(/path/to/segmentation/pipeline)`).

An example file has been included in the classicalpipeline/ folder called example.m that provides starting code for using the pipeline.

### Deep Learning Pipeline
Google Colaboratory Notebooks for the classification and segmentation pipelines can be found in dl_analysis/ 

Pre-trained models are also saved under dl_analysis, under classification.ckpt and unet.ckpt