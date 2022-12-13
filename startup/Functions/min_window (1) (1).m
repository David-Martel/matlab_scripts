function [min_vals,min_idx] = min_window(data,window,varargin)


if isempty(window)
    [min_vals,min_idx] = min(data,varargin{:});
elseif length(varargin)==2
%     data_idx = ~cellfun('isempty',varargin);
    vargs = varargin( ~cellfun('isempty',varargin));
    dim = vargs{1};

else

    dim = 2;


end
    other_data = data;
    size_vec = size(other_data);
    dims = 1:length(size_vec);

    otherdims = dims(dims~=dim);

    other_data = permute(other_data,[dim otherdims]);

    min_win = min(window);
    max_win = max(window);
    search_idx = 1:size_vec(dim);
    search_idx = reshape(search_idx>=min_win & search_idx<=max_win,[],1);


%     search_idx = repmat(search_idx>=min_win ...
%         & search_idx<=max_win,otherdims);
    
    
    [min_vals,min_idx] = min(other_data(search_idx,:));
    min_idx = min_idx+min_win;
end
















