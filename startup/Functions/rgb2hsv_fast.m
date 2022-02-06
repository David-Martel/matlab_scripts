function [h,s,v] = rgb2hsv_fast(r,g,b,opt_typ,opt_sel)
%RGB2HSV_FAST does the same as RGB2HSV
%but faster and less memory exhaustive,
%especially on images which are stored as integers.
%
%RGB2HSV_FAST(IMG,'single')
%You can specify the optional argument 'single'
%to use single precision.
%This saves memory and is sufficiently exact, anyhow.
%
%RGB2HSV_FAST(IMG,'','H')
%Optionally, you can specify which channels to calculate:
%'HSV' is default.
%'H' calculates hue only.
%'S' calculates saturation only.
%'V' calculates value only.
%'HS', 'HV', or 'SV' are also possible.
% How to make it efficient?
%  -  Don't cast integer images to floating point too soon.
%     Operate on integers as far as possible and
%     take advantage of functions like IMLINCOMB().
%  -  Avoid FIND(). Directly index via binary arrays instead.
%  -  Avoid RESHAPE().
%     http://blogs.mathworks.com/loren/?p=28
%
% Alexander Ihlow, Germany, Oct 2006
% Version 1.1
% 2006-11-02 added support for individual channel selection
%            version 1.0 saved to rgb2hsv_fast_10.m
%
%
% RGB2HSV_FAST has a high cyclomatic complexity
% due to lots of case checking.
%
% Please report bugs or suggestions to ml-user@web.de.
threeD = ~ismatrix(r);
if (nargin < 4), opt_typ = ''; end
if (nargin < 5), opt_sel = ''; end
if (nargin > 1) && ~isnumeric(g), opt_typ = g; end
if (nargin > 2) && ~isnumeric(b), opt_sel = b; end
%disp(['threeD = ' num2str(threeD)])
%disp(['opt_typ = ' opt_typ])
%disp(['opt_sel = ' opt_sel])
temp_class = class(r);

% Check input class
if isa(r,'gpuArray')
    temp_class = classUnderlying(r);
end

switch (temp_class)
    case 'uint8'
        immax = 255;
    case 'uint16'
        immax = 65535;
    case 'double'
        immax = 1;
    case 'single'
        immax = 1;
        % If input is single, output single per default.
        if isempty(opt_typ), opt_typ = 'single'; end
        
    otherwise
        error('Only images of type uint8, uint16, single, and double are supported!')
end
% Default output is double.
if isempty(opt_typ), opt_typ = 'double'; end
% Use single precision if optionally specified.
% This saves 1/2 of memory and is exact enough
% for those simple colorspace transformations.
% single : out_typ = 1
% double : out_typ = 2
switch lower(opt_typ(1))
    case 's'
        out_typ = 1;
    otherwise
        out_typ = 2;
end

% Helper functions to map float either to single or double.
if out_typ == 1
    im2float = @im2single;
    float = @single;
    floatstr = 'single';
else
    im2float = @im2double;
    float = @double;
    floatstr = 'double';
end
immax = float(immax);
if threeD
    % Split RGB image into R G B channels and
    % thereby support arbitrary dimensional images.
    % R G B is assumed to be contained in the third dimension.
    sizc = num2cell(size(r));
    for k=1:numel(sizc), sizc{k} = ':'; end
    sizc{3} = 2;
    g = r(sizc{:});
    sizc{3} = 3;
    b = r(sizc{:});
    sizc{3} = 1;
    r = r(sizc{:});
elseif nargin==1
    % split N x 3 matrix into three vectors
    g = r(:,2); b = r(:,3); r = r(:,1);
end
siz = size(r);
if isempty(opt_sel), opt_sel = 'HSV'; else opt_sel = upper(opt_sel); end
if any( (opt_sel ~= 'H') & (opt_sel ~= 'S') & (opt_sel ~= 'V') )
    error('Invalid optional argument! Please use ''H'', ''S'', or ''V''')
end

v = max(max(r,g),b);
if any(opt_sel == 'H') || any(opt_sel == 'S')
    s = imsubtract(v, min(min(r,g),b));
    z = ~s;
    s = im2float(s);
    s(z) = 1;
    
    if any(opt_sel == 'H')
        % Calculating HUE via IMLINCOMB() is highly efficient.
        sizc = num2cell(siz);
        h(sizc{:}) = float(0);
        k = (r == v);
        h(k) =     imlincomb(1,g(k),-1,b(k),floatstr)./(immax*s(k));
        k = (g == v);
        h(k) = 2 + imlincomb(1,b(k),-1,r(k),floatstr)./(immax*s(k));
        k = (b == v);
        h(k) = 4 + imlincomb(1,r(k),-1,g(k),floatstr)./(immax*s(k));
        
        h = (1/6) * h;
        k = (h < 0);
        h(k) = h(k) + 1;
        
        h(z) = 0;
    end
    
    if any(opt_sel == 'S') || any(opt_sel == 'V')
        k = (v ~= 0);
        v = im2float(v);
        if any(opt_sel == 'S')
            s(k) = (~z(k)).*s(k)./v(k);
            s(~k) = 0;
        end
    end
else
    v = im2float(v);
end

if ~any(opt_sel == 'H'), h = float([]); end
if ~any(opt_sel == 'S'), s = float([]); end
if ~any(opt_sel == 'V'), v = float([]); end
if nargout <= 1
    if (threeD || nargin>=3)
        h = cat(3,h,s,v);
    else
        h = [h s v];
    end
else
    switch opt_sel
        case 'HSV'
            %
        case 'H'
            disp('There is more than one output variable given, but only HUE is assigned to the first one!')
        case 'S'
            h = s;
            disp('There is more than one output variable given, but only SAT is assigned to the first one!')
        case 'V'
            h = v;
            disp('There is more than one output variable given, but only VAL is assigned to the first one!')
        case 'HS'
            if nargout > 2
                disp('There are more than two output variables given, but only HUE and SAT are assigned to the first two!')
            end
        case 'HV'
            s = v;
            if nargout > 2
                disp('There are more than two output variables given, but only HUE and VAL are assigned to the first two!')
            end
        case 'SV'
            h = s;
            s = v;
            if nargout > 2
                disp('There are more than two output variables given, but only SAT and VAL are assigned to the first two!')
            end
        otherwise
            disp('Unrecognized output - please check what happened!')
    end
end
