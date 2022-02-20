function [counts,binned] = cust_bins(data,edges)

base_size = size(data);
data_temp = reshape(data,numel(data),1);

counts = zeros(1,numel(edges)-1);
binned = zeros(size(data),class(data));

for binval = 1:(length(edges)-1)
   
    bin_idx = data_temp>edges(binval) & data_temp<=edges(binval);
    
    counts(binval) = sum(bin_idx);
    binned(bin_idx) = binval;
    
end

% binned = reshape(binned,base_size);
% 






