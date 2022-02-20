function [max_vals,max_idx] = max_window(data,window,varargin)


if isempty(window)
    [max_vals,max_idx] = max(data,varargin{:});
else
    if ismember(length(varargin),[1 2])
        %     data_idx = ~cellfun('isempty',varargin);
        vargs = varargin( ~cellfun('isempty',varargin));
        dim = vargs{1};

    else
        dim = 2;
    end
    other_data = data;
    size_vec = size(other_data);

    if dim > 1
        dims = 1:length(size_vec);
        otherdims = dims(dims~=dim);
        other_data = permute(other_data,[dim otherdims]);
    end

    min_win = min(window);
    max_win = max(window);
    search_idx = 1:size_vec(dim);
    search_idx = reshape(search_idx>=min_win & search_idx<=max_win,[],1);


    [max_vals,max_idx] = max(other_data(search_idx,:));
    max_idx = max_idx+min_win;
end

end














