clear
clc
close all

%%Useful tools:
%https://imagej.net/plugins/trackmate/analyzing-results-with-matlab
%https://homepages.inf.ed.ac.uk/rbf/HIPR2/pntops.htm


%%
% run("Set Scale...", "distance=3.65 known=1 pixel=1 unit=um global");
% run("Measure");
% run("Split Channels");
%
% close();
% close();

%Matlab equivalent
dist_scalar = 3.65;%um/pixel
base_dir = pwd;
file_name = fullfile(base_dir,'immuno1.tif');
img_base = imread(file_name);
img_color = im2double(img_base);

img = rgb2gray(img_color);

% figure(1)
% clf(1)
% hold on
% 
% imshow(img,[]);

% run("Enhance Contrast...", "saturated=0.2 normalize");
sat_values = [0.2 0.8];
img_enhance = rescale(img,0,1,...
    'inputmin',min(sat_values),'inputmax',max(sat_values));

% figure(2)
% clf(2)
% hold on
% 
% imshow(img_enhance,[]);


%run("Subtract Background...", "rolling=10");
% img_enhance = sauvola(img_enhance,[10 10]);
% se = strel('square',10);
% 
% img_noback = imbothat(img_enhance,se);
img_noback = sauvola(img_enhance,[10 10]);
img_noback = img_enhance.*img_noback;

% figure(3)
% clf(3)
% 
% imshow(img_noback,[]);

%run("Auto Threshold...", "method=MaxEntropy white");
% [threshval,img_thresh] = maxentropie(img_noback);

img_thresh = imbinarize(img_noback);

% figure(4)
% clf(4)
% imshow(img_thresh);

%% 
%https://imagej.net/plugins/classic-watershed
% run("Invert");
% run("Watershed");
%help watershed
% img_d = bwdist(~img_thresh);
% 
% img_d = -img_d;
% img_d(~img_thresh) = Inf;
% 
% 
% img_watershed = watershed(img_thresh);
% img_watershed(~img_thresh) = 0;

im_props = regionprops(img_thresh,'Area','Centroid','BoundingBox',...
    'Circularity','Eccentricity','PixelIdx');

keep_idx = true(height(im_props),1);

%filter by area
area_vec = cat(1,im_props.Area);
area_bounds = [5 inf]; %[3 16].^2; %radius squared
area_idx = area_vec>=min(area_bounds) ...
    & area_vec<=max(area_bounds);
keep_idx = keep_idx & (area_idx);

%filter by circularity
% circ_vec = cat(1,im_props.Circularity);
% circ_bounds = [0.7 1.3];
% circ_idx = circ_vec>=min(circ_bounds) ...
%     & area_vec<=max(circ_bounds);
% keep_idx = keep_idx & circ_idx;

im_props_keep = im_props(keep_idx);

%% 
centroids = cat(1,im_props_keep.Centroid);
bb = cat(1,im_props_keep.BoundingBox);


show_image = img_base;

for iter = 1:length(im_props_keep)
    show_image = insertShape(show_image,...
        'rectangle',bb(iter,:),...
        'Color','Blue','Opacity',1,'linewidth',4);
    show_image = insertMarker(show_image,centroids,...
        'o','color','green','Size',10);
        
end

figure(5)
clf(5)

imshow(show_image,[])

figure(6)
clf(6)

subplot(1,2,1)
hold on

histogram(cat(1,im_props_keep.Area),'numbins',20)


%
% run("Analyze Particles...", "size=5-Infinity pixel show=Outlines summarize");











