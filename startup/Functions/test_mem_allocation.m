function frame_data_store = test_mem_allocation(frame_size,num_frame,num_cam,num_vid)

% frame_size = [740 520 3];
%
% num_frame = 800;
%
% num_cam = 4;
% num_vid = 20;

xsize = frame_size(1);
ysize = frame_size(2);
color = frame_size(3);
temp_frame = zeros(xsize,ysize,color,'uint8');

frame_data_store = cell(num_vid,num_cam,num_frame);

temp_iter = 1;
for vid_iter = 1:num_vid
    for cam_iter = 1:num_cam
        for frame_iter = 1:num_frame
            
            data_frame = temp_frame;
            data_frame(end) = temp_iter;
            
            frame_data_store{vid_iter,cam_iter,frame_iter} = data_frame;
            temp_iter = temp_iter + 1;
            
        end
    end
end





















