function [gray_video,rgb_video_local] = video_rgb2gray(rgb_video,varargin)

[xdim,ydim,~,num_frames] = size(rgb_video);

conv_factor = single([0.299; 0.587; 0.114]);

if xdim~=ydim
    rgb_video_local = imresize(rgb_video,[512 512]);
    xdim = 512;
    ydim = 512;
else
    rgb_video_local = rgb_video;
end

% mean_image = im2gray(mean(im2single(rgb_video(:,:,:,[1 2])),4));

gray_video = reshape(pagemtimes(...
    reshape(single(rgb_video_local),xdim*ydim,3,num_frames),...
    repmat(conv_factor,1,1,num_frames)),xdim,ydim,1,num_frames);


if ~isempty(varargin)
    if any(contains(varargin,'gaussfilt'))
        gray_video = imgaussfilt(gray_video,1,'padding','symmetric');
    end

    if any(contains(varargin,'histmatch'))
        for frame_iter = 2:num_frames
            gray_video(:,:,:,frame_iter) = ...
                imhistmatch_local(gray_video(:,:,:,frame_iter),...
                gray_video(:,:,:,frame_iter-1),128);
        end
    end

    if any(contains(varargin,'integer'))
        gray_video = im2uint8(gray_video);
    end

end

    function base_im = imhistmatch_local(base_im,ref_im,nbins)

        if ~isequal(base_im,ref_im)
            base_im = histeq(base_im,imhist(ref_im,nbins));
        end

    end

end


%         gray_frame = imgaussfilt(gray_video(:,:,:,frame_iter)

%         if frame_iter == 1
%             old_frame = gray_frame;
%         else
%         gray_frame = imhistmatch_local(gray_frame,old_frame,128);
%
%         end
% %         old_frame = gray_frame;
