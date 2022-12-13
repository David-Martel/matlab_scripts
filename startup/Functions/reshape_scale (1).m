function [varargout] = reshape_scale(vid_data,varargin)

if isempty(varargin)
    scale_factor = 1;
else
    scale_factor = varargin{1};
end

size_mat = size(vid_data);
frame_size = size_mat(1)*size_mat(2);

if numel(size_mat) == 4
    num_frames = size_mat(4);
else
    num_frames = 1;
end

vid_matrix = zeros(frame_size*num_frames,size_mat(3),class(vid_data));

frame_idx = ones(frame_size,num_frames);
frame_idx = cumsum(frame_idx,2);
frame_idx = reshape(frame_idx,frame_size*num_frames,1);

for frame_iter = 1:num_frames
    frame = reshape(vid_data(:,:,:,frame_iter),frame_size,size_mat(3));
    vid_matrix(frame_idx == frame_iter,:) = frame;
end

varargout{1} = vid_matrix;
varargout{2} = frame_size;
varargout{3} = frame_idx;













