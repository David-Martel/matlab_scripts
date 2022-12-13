function [vid_data,varargout] = read_mp4_fast(vid_file)

read_obj = VideoReader(vid_file);

vid_data = read(read_obj);

varargout{1} = read_obj.NumFrames;
varargout{2}  = [read_obj.Height read_obj.Width];












