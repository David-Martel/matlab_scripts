function [vid_matrix,thresh_data] = read_mp4_matrix(thresh_data,varargin)
%thresh_data.vid_file
%thresh_data.num_frame
%thresh_data.frame_size
%
%
% p = inputParser;

if isa(thresh_data,'struct')
    
elseif isa(thresh_data,'char')
    thresh_data = cell2struct({thresh_data,500,[512 512]},{'vid_file','num_frame','frame_size'},2);
elseif isa(thresh_data,'cell') && length(thresh_data)==1
    thresh_data = cell2struct(cat(2,thresh_data,{500,[512 512]}),{'vid_file','num_frame','frame_size'},2);
end

vid_opts = {"ImageColorSpace","RGB","VideoOutputDataType","uint8","PlayCount",1};
vfr = vision.VideoFileReader(thresh_data.vid_file,vid_opts{:});

% num_pixel = prod(frame_size);
% out_frame = [];
% get_procframe();
% if isfield(thresh_data,'frame_size')

thresh_data.color_framesize = [thresh_data.frame_size 3];
thresh_data.color_vidsize = [thresh_data.frame_size(1)*thresh_data.frame_size(2) 3];

vid_matrix = zeros([thresh_data.color_vidsize thresh_data.num_frame],'uint8');
vid_matrix(numel(vid_matrix)) = uint8(0);

% vid_struct = struct();
% head = struct('number', cell(1, 10), 'pck_rv', cell(1, 10));

% vid_matrix = repmat(reshape(imresize(vfr.step(),resize_dim),num_pixel,3),1,1,num_frame);

% frame_iter = 1;
for frame_iter=1:thresh_data.num_frame
%     vid_matrix(:,:,frame_iter) = reshape(imresize(vfr.step,thresh_data.frame_size),...
%         thresh_data.color_vidsize([1 2]));
    %vid_struct(frame_iter).cdata = vfr.step;
    
    vid_matrix(:,:,frame_iter) = get_frame();
    if vfr.isDone
        if frame_iter < thresh_data.num_frame
            vid_matrix(:,:,frame_iter:thresh_data.num_frame) = [];
            thresh_data.num_frame = (frame_iter-1);
        end
        
        break
    end
end
vfr.release;

% vid_matrix = imresize(cat(4,vid_struct(:).cdata),thresh_data.frame_size); %structfun(@(x) imresize(x,thresh_data.frame_size),vid_struct);

if isempty(varargin)
    vid_matrix = single(vid_matrix);
    
    cb_offset = 20;
    cr_offset = -20;
    
    %     T = ([ ...
    %         65.481 128.553 24.966;...
    %         -37.797-cb_offset/2 -74.203-cb_offset/2 112+cb_offset; ... %CB channel
    %         112+cr_offset -93.786-cr_offset/2 -18.214-cr_offset/2]/255)'; %CR channel
    %     offset = [16 128 128]/255;
    T = ([65.481 128.553 24.966;...
        -37.797-cb_offset/2 -74.203-cb_offset/2 112+cb_offset; ... %CB channel
        112+cr_offset -93.786-cr_offset/2 -18.214-cr_offset/2]); %CR channel
    offset = [16 128 128];
    
    vid_matrix = (pagemtimes(vid_matrix,'none',T,'transpose')+offset)/255;
    
    %     vid_matrix = pagemtimes(...
    %         reshape(vid_matrix,[thresh_data.color_vidsize thresh_data.num_frame]),...
    %         repmat(T,1,1,thresh_data.num_frame))+offset;
    
    vid_matrix = vid_matrix ...
        + mean(repmat(vid_matrix(:,:,1),1,1,thresh_data.num_frame)-vid_matrix,1,'native');
    
end

vid_matrix = reshape(vid_matrix,[thresh_data.color_framesize thresh_data.num_frame]);

%%

    function frame = get_frame
        frame = reshape(imresize(vfr.step,thresh_data.frame_size),...
            thresh_data.color_vidsize);
    end



end


% vid_matrixd = vid_matrix;
%   vid_matrixd = pagemtimes(...
%         reshape(vid_matrixd,[prod(thresh_data.frame_size) 3 thresh_data.num_frame]),...
%         repmat(T,1,1,thresh_data.num_frame)) + offset;
