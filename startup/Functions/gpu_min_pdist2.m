function [gr_pts,mins] = gpu_min_pdist2(X,Y,factor_size,cl_thresh)


% mins = nan(size(X,1),1,'gpuArray'); %gpuArray
mins = nan(size(X,1),1);

gr_pts = false(size(X,1),1);
compute_size = floor(size(X,1)/factor_size);

% Ysmall = gpuArray(Y); %gpuArray
Ysmall = Y; %gpuArray

for idx = 1:factor_size
    
    prob_idx = ((idx-1)*compute_size+1):(idx*compute_size);
    
%     Xsmall = gpuArray(X(prob_idx,:)); %gpuArray
      Xsmall = X(prob_idx,:);
      
    small_dist = pdist2(Xsmall,Ysmall);
    [~,small_mins] = min(small_dist,[],2);
    
    mins(prob_idx,:) = small_mins;
%     gr_pts(prob_idx,:) = gather(small_mins>=cl_thresh); %gpuArray
      gr_pts(prob_idx,:) = small_mins>=cl_thresh;
      disp(idx)
end














