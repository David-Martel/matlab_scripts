function frame = pts2frame(pts,frame_size)

if ~isa(pts,'gpuArray')
    class_type = 'logical';
else
    class_type = 'gpuArray';
end

frame = false(frame_size(1),frame_size(2),class_type);
frame(sub2ind(frame_size,pts(:,1),pts(:,2))) = true;





