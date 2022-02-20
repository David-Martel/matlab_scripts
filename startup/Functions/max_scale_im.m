function rgb_data = max_scale_im(rgb_data)

rgb_data = bsxfun(@minus,rgb_data,min(rgb_data));
rgb_data = bsxfun(@rdivide,rgb_data,max(abs(rgb_data)));

if ~isa(rgb_data,'double')
    rgb_data = rgb_data.*255;
end