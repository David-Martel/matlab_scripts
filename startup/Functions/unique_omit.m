function x = unique_omit(x,varargin)

x = unique(x,varargin{:});
if any(isnan(x),"all")
    x = x(~isnan(x));
end

