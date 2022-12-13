function [vid_cell,vid_info] = read_mp4_ycbcr(vid_file,frame_max,frame_resize)

if isempty(frame_max)
    frame_max = 478;
end

if isempty(frame_resize)
    frame_resize = [512 512];
end

vfr = vision.VideoFileReader(vid_file);

vfr.ImageColorSpace = 'RGB'; %'YCbCr 4:2:2';
vfr.VideoOutputDataType = 'inherit';
vfr.PlayCount = 1;

vid_info = vfr.info;


% [Y,CB,CR] = step(vfr);
frame = imresize(vfr.step,frame_resize);

% vid_mat = repmat(frame,1,1,1,frame_max);
vid_cell = repmat({frame},1,frame_max);

for frame_iter=2:frame_max
    
    
    if vfr.isDone
        if frame_iter < frame_max
            %vid_mat(:,:,:,frame_iter:frame_max) = [];
            vid_cell(frame_iter:frame_max) = [];
        end
        
        break
    else
        vid_cell{frame_iter} = imresize(vfr.step,frame_resize);
    end
    
end
vfr.release;



end

% function frame = resize_func(frame,frame_resize)
%     frame = imresize(frame,frame_resize);
% end


