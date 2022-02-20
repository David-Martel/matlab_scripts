function ear_pts = compute_ear_data(vid_file,save_vid,colors,cl_thresh)

%% read in vid data
% [vid_data,frame_size,num_frames] = read_mp4_fast(vid_file);
[vid_data,num_frames,frame_size] = read_mp4_fast(vid_file);

num_pts = numel(vid_data);

[vid_data_big,~] = reshape_scale(vid_data);
vid_data_big = single(vid_data_big);

%% process video
 gpu_scale = num_frames;
tic
[gr_pts,~] = gpu_min_pdist2(vid_data_big,colors,gpu_scale,cl_thresh);
toc
%% cluster green pixels into usable data points, assign to "ears"
[ear_assigns,pt_array] = get_ear_pts(gr_pts,frame_size,num_frames,num_pts,'use_gpu');
save_vars = {'ear_pts','ear_assigns','gr_pts'};

if ~isempty(ear_assigns)
    ear_pts = get_centroids(ear_assigns,pt_array,num_frames);
    
else
    ear_pts = [];
    
    save_vid = replace(save_vid,'.mat','BAD.mat');
    
end

save(save_vid,save_vars{:});





















