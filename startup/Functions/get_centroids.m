function ear_pts = get_centroids(ear_assigns,pt_array,num_frames)

ear_pts = nan(num_frames,4);
for idx = 1:num_frames
    
    ear_idx = ear_assigns==1 & pt_array(:,3) == idx;
    ear_pts(idx,[1 2]) = median(pt_array(ear_idx,[1 2]));
    
    ear_idx = ear_assigns==2 & pt_array(:,3) == idx;
    ear_pts(idx,[3 4]) = median(pt_array(ear_idx,[1 2]));
    
end













