function varargout = get_green_pts_gpu(im,colors,cl_thresh,varargin)
%function uses color model and green location in color model to classify
%points as a shade of ear marker green or not. Pts returns empty if less
%than 2% of pixels are classified as green.

x=size(im,1);
y=size(im,2);
scale = 1.5;
bad_pts_thresh = 0.01;
left_bound = 180;
right_bound = 520;
color_dim = 3;

med_filt_size = [7 7];

% find if boundary values are specified
if ~isempty(varargin)
    
    lf_bound = contains(varargin,'left_bound');
    if any(lf_bound)
        lf_idx = find(lf_bound) + 1;
        left_bound = varargin{lf_idx};
    end
    
    rt_bound = contains(varargin,'right_bound');
    if any(rt_bound)
        rt_idx = find(rt_bound) + 1;
        right_bound = varargin{rt_idx};        
    end
end

%don't include parts of image away from guinea pig head, or ass
left_bound = floor(left_bound.*scale); %200
right_bound = ceil(right_bound.*scale); %540

%help speed up computation, remove if undeeded for accuracy. speed up = x4
temp = imresize(im,scale);

temp_lin = single(reshape(temp,scale.^2*x*y,color_dim));

color_dist = pdist2(temp_lin,colors); %sqDistance(temp_lin',colors'); %%slooowwww, faster than knnsearch
[~,close_color] = min(color_dist,[],2);

gr_pts = close_color >= cl_thresh;

gr_pts = reshape(gr_pts,scale.*x,scale.*y);
gr_pts(:,1:left_bound) = false;
gr_pts(:,right_bound:end) = false;

percent_pts = sum(gr_pts(:))./numel(gr_pts)*100;
if percent_pts <= bad_pts_thresh
    gr_pts = [];
    coords = [];
else
    gr_pts = medfilt2(gr_pts,med_filt_size);
    gr_pts = single(gr_pts);
    gr_pts = imresize(gr_pts,[x y]);
    coords = color2coords(gr_pts);
    
end

varargout{1} = coords; %gr_pts;
varargout{2} = gr_pts;



















