function SEM = nansem(x,varargin)

if ~isempty(varargin)
    dim = varargin{1};
else
    dim = 1;
end

SEM = std(x,0,dim,'omitnan')./sqrt(sum(~isnan(x),dim));





