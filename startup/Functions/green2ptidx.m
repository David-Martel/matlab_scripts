function pt_data = green2ptidx(gr_pts)

num_frames = size(gr_pts,3);

pt_data = nan(sum(gr_pts(:)),3);
pt_iter = 1;
for idx = 1:num_frames
    
    frame = gr_pts(:,:,idx);
    [Xpt,Ypt] = find(frame);
    if ~isempty(Xpt)
        Tpt = idx.*ones(size(Xpt));
    
    
        up_val = (numel(Tpt)+pt_iter-1);
        pt_idx = pt_iter:up_val;
 
        pt_data(pt_idx,:) = [Xpt Ypt Tpt];
        pt_iter = up_val;
    end
    
end

pt_data(any(isnan(pt_data),2),:) = [];







