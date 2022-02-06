function [img_data,varargout] = process_image(filename)
%return structure containing pixel/centroid information, as well as a
%marked image for additional/further analysis.

param_vals = struct;
param_vals.sat_values = [0.2 0.8];
param_vals.back_filter = [10 10];
param_vals.area_bound = [5 inf];

if exist(filename,'file')~=2
    fprintf(1,'cannot find: %s\n',filename);
    return
end

img_base = imread(filename);
img_color = im2double(img_base);

img = rgb2gray(img_color);

% run("Enhance Contrast...", "saturated=0.2 normalize");
% sat_values = [0.2 0.8];
img_enhance = rescale(img,0,1,...
    'inputmin',min(param_vals.sat_values)...
    ,'inputmax',max(param_vals.sat_values));

% background_filter_size = [10 10];
img_noback = sauvola(img_enhance,param_vals.back_filter);
img_noback = img_enhance.*img_noback;

img_thresh = imbinarize(img_noback);

%%
grpdata = regionprops(img_thresh,'Area','Centroid','BoundingBox',...
    'Circularity','Eccentricity','PixelIdx');

keep_idx = true(height(grpdata),1);

%filter by area
area_vec = cat(1,grpdata.Area);
% area_bounds = [5 inf]; %[3 16].^2; %radius squared
area_idx = area_vec>=min(param_vals.area_bound) ...
    & area_vec<=max(param_vals.area_bound);
keep_idx = keep_idx & (area_idx);

%filter by circularity
% circ_vec = cat(1,im_props.Circularity);
% circ_bounds = [0.7 1.3];
% circ_idx = circ_vec>=min(circ_bounds) ...
%     & area_vec<=max(circ_bounds);
% keep_idx = keep_idx & circ_idx;

grpdata = grpdata(keep_idx);

img_data.grpdata = grpdata;
img_data.params = param_vals;

[file_path,file_part,file_ext] = fileparts(filename);

img_data.path = file_path;
img_data.file = file_part;
img_data.ext = file_ext;


if nargout>=2
    %%
    centroids = cat(1,grpdata.Centroid);
    bb = cat(1,grpdata.BoundingBox);
    
    
    show_image = img_base;
    
    for iter = 1:length(grpdata)
        show_image = insertShape(show_image,...
            'rectangle',bb(iter,:),...
            'Color','Blue','Opacity',1,'linewidth',4);
        show_image = insertMarker(show_image,centroids,...
            'o','color','green','Size',10);
        
    end
    
    varargout{1} = show_image;
    
end









