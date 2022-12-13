function [vid_data,frame_size,num_frames] = read_mp4_video(vid_file,varargin)
%vid_file = 'N1_eight_ten_GAP_Trial_1.mp4';

vid_read = VideoReader(vid_file);

num_frames = floor(vid_read.Duration*vid_read.FrameRate);
xdim = vid_read.Width;
ydim = vid_read.Height;

scale = 1;
if ~isempty(varargin)
    scale = varargin{1};
end

frame_size = floor(scale.*[ydim xdim]);

color = 3;

vid_data = zeros(frame_size(1),frame_size(2),color,num_frames,'uint8');

for idx = 1:num_frames
    frame = readFrame(vid_read);
    vid_data(:,:,:,idx) = imresize(frame,scale);
end












