clear
clc
close all

images = getAllFiles(pwd,'findstr','.tif','skipstr','.link');

derp_im = images{1};

derp_data = imread(derp_im);

im_data = rgb2gray(derp_data);
im_float_data = rescale(im2single(im_data),0,1);

var_func = @(block_struct) std2(block_struct.data) * ones(size(block_struct.data));

block_size = [5 5];
var_image = blockproc(im_float_data,block_size,var_func);

var2_image = medfilt2(im_float_data,block_size);

figure(2)
clf(2)
hold on

mesh(im_float_data)

%%
figure(3)
clf(3)

subplot(1,2,1)
hold on


mean_inten = mean(im_float_data,'all');
median_inten = median(im_float_data,'all');

base_size = size(im_float_data);

float_lin = im_float_data(:);

min_vals = mink(unique(float_lin),2);
float_lin(float_lin==min_vals(1)) = min_vals(2);

float_lin_log = log10(float_lin);

nbin = 256;
[bins,counts,bin_im] = histcounts(float_lin_log,...
    'NumBins',nbin,'normalization','pdf');
counts(end) = [];
bin_im = reshape(bin_im,base_size);

bar(counts,bins,1,'r','edgecolor','none')

subplot(1,2,2)
hold on
zscore_im = zscore(float_lin);
zscore_im = reshape(zscore_im,base_size);

[xx,yy] = meshgrid(1:base_size(2),1:base_size(1));

mesh(yy,xx,zscore_im)
xlim([0 base_size(1)])
ylim([0 base_size(2)])
% mesh(im_float_data)

%%
up_val_im = rescale(float_lin-median(float_lin),0,1,'InputMin',0);
up_val_im = reshape(up_val_im,base_size);

% figure(12)
% clf(12)
% hold on
% 
% mesh(yy,xx,up_val_im)
% xlim([0 base_size(1)])
% ylim([0 base_size(2)])

prom_size = 0.6;

outlier_im_x = islocalmax(up_val_im,1,...
    'FlatSelection','all','MinProminence',prom_size);
outlier_im_y = islocalmax(up_val_im,2,...
    'FlatSelection', 'all','MinProminence',prom_size);
% outlier_im = reshape(up_val_outlier,base_size);

outlier_im = (outlier_im_x | outlier_im_y);
se = strel('disk',9);

% outlier_im = imdilate(outlier_im,se);
outlier_im = imclose(outlier_im,se);

%%
im_props = regionprops(outlier_im,'Area','Centroid','BoundingBox',...
    'Circularity','Eccentricity','PixelIdx');

area_vec = cat(1,im_props.Area);
area_bounds = [3 16].^2; %radius squared
area_idx = area_vec>=min(area_bounds) ...
    & area_vec<=max(area_bounds);

circ_vec = cat(1,im_props.Circularity);
circ_bounds = [0.7 1.3];
circ_idx = circ_vec>=min(circ_bounds) ...
    & area_vec<=max(circ_bounds);

keep_idx = area_idx | circ_idx;

im_props_keep = im_props(keep_idx);

centroids = cat(1,im_props_keep.Centroid);
bb = cat(1,im_props_keep.BoundingBox);

show_image = derp_data;

for iter = 1:length(im_props_keep)
    show_image = insertShape(show_image,...
        'rectangle',bb(iter,:),...
        'Color','Blue','Opacity',1,'linewidth',4);
    show_image = insertMarker(show_image,centroids,...
        '*','color','green');
        
end

figure(13)
clf(13)

imshow(show_image)

figure(14)
clf(14)
imshow(outlier_im)
% hold on
% 
% plot(

% isequal(derp_data(:,:,1),derp_data(:,:,2))
% 
% figure(10)
% clf(10)
% mesh(im_data)
% 
% im_spec = fft2(im_data);
% im_spec_center = fftshift(im_spec);
% im_spec_center_mag = 20*log10(abs(im_spec_center));


% imshow(derp_data)
% 
% figure(11)
% clf(11)
% mesh(im_spec_center_mag);
% mesh(derp_data(:,:,3))


% 











