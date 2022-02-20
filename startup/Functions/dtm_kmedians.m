function grp_assign = dtm_kmedians(data,num_clust)

max_iter = 100;
move_thresh = .01;

num_pts = size(data,1);
pt_idx = randsample(num_pts,floor(num_pts/10),false);


data = gpuArray(data);
num_clust = gpuArray(num_clust);

trial_iter = 0;
control_var = true;
while control_var
    
    
    if trial_iter == 0            
        [~,median_vals] = kmeans(data(pt_idx,[1 2]),num_clust);
        median_vals = [median_vals median(data(:,3)).*ones(2,1,class(data))];
    end
    old_median_vals = median_vals;
    
    %gpu part
    dists = pdist2(data,median_vals);
    [~,assigns] = min(dists,[],2);
    
    for idx = 1:num_clust
        median_vals(idx,:) = median(data(assigns == idx,:));
    end
    
    
    trial_iter = trial_iter + 1;
    
    if trial_iter >= max_iter
        control_var = false;
    end
    
    if norm(old_median_vals-median_vals) <= move_thresh
        control_var = false;
    end
end


grp_assign = gather(assigns);



















