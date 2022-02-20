function [outliers,mad_value,mad_score] = get_median_outlier(data,dim,scalar)
% as K*MEDIAN(ABS(A-MEDIAN(A))) where K is the scaling factor and is 
%     approximately 1.4826.

% C = {1,1,1,...1,,':'};
% A(C{:})
% base_dim = size(data);
% dim_vec = 1:numel(base_dim);
% 
% dim_select = repmat({1},1,numel(base_dim));
% dim_select{dim_vec(ismember(dim_vec,dim))} = ':';
% 
% data_temp = data(dim_select{:});
% 
% nd = ndims(data);
% proto = arrayfun(@randi, size(data), 'uniform', 0);
% dim_wanted = randi(nd);
% proto{dim_wanted} = ':';
% random_vector_in_N_space = data(proto{:});

% rot_dims = 1:length(base_dim);
% rot_dims = cat(2,dim,rot_dims(~ismember(rot_dims,dim)));
% 
% data_temp = permute(data,rot_dims);

k = 1.4826;
data_median = median(data,dim,'omitnan');
mad_score = abs(data-data_median);

mad_value = k*median(mad_score,dim,'omitnan');

mad_score = mad_score./mad_value;

outliers = mad_score>=scalar;

% outliers = mad_score>=(scalar*mad_value) ...
%     | mad_score<=(-scalar*mad_value);

% figure(20)
% clf(20)
% 
% histogram(mad_score,'numbins',500)
% 
% [derp_outlier,lt,upt,cent] = isoutlier(data,1);
% 
% sum(outliers)
% sum(derp_outlier)
%  isequal(outliers,derp_outlier)






