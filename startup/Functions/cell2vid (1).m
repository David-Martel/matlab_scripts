function mat = cell2vid(vid)

frame_size = size(vid{1});
frame_count = size(vid);
frame_count = max(frame_count);

mat = nan(frame_size(1),frame_size(2),frame_count);

for idx = 1:frame_count
    mat(:,:,idx) = vid{idx};
    
end
















