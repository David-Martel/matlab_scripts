function out_data = linearVector(varargin)

out_data = [];
if all(cellfun(@isnumeric,varargin))
    in_data = cat(1,varargin{:});

    out_data = reshape(in_data,numel(in_data),1);
end
