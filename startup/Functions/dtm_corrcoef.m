function [r,p,xout,yout] = dtm_corrcoef(xdata,ydata,varargin)

bad_vals = isnan(xdata) | isnan(ydata);
if isrow(bad_vals)
    bad_vals = bad_vals';
end

xdata(bad_vals) = [];
ydata(bad_vals) = [];

[r,p] = corrcoef(xdata,ydata);
r = r(1,2);
p = p(1,2);


if any(contains(varargin,'origin'))
    center_line = true;
else
    center_line = false;
end

[xout,yout] = corline(xdata,ydata,center_line);










