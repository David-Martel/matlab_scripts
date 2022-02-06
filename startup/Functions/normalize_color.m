function norm_frame = normalize_color(frame)

if ~isa(frame,'single') || ~isa(frame,'double')
    frame = single(frame);
end

norm_frame = frame;

% red_min = min(frame(:,:,1));
% red_max = max(frame(:,:,1));
% 
% blue_min = min(frame(:,:,2));
% blue_max = max(frame(:,:,2));
% 
% green_min = min(frame(:,:,3));
% green_max = max(frame(:,:,3));

for color_iter = 1:3
    color_min = min(frame(:,:,color_iter));
    color_max = max(frame(:,:,color_iter));
    
    norm_frame(:,:,color_iter) = (norm_frame(:,:,color_iter)-color_min)./color_max;
end

frame_min = min(norm_frame(:));
frame_max = max(norm_frame(:));

norm_frame = (norm_frame-frame_min)./max(frame_max);


