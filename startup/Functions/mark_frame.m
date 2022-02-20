function mark_frame = mark_frame(frame,pts,color)

mark_frame = frame;
color_reshape = reshape(color,1,1,3);

[x,y] = size(pts);

for pt_iter = 1:x
    mark_frame(pts(pt_iter,2),pts(pt_iter,1),:) = color_reshape;
end


