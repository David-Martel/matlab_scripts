function [low,high] = get_q10(x,y,rf_data)


[bf,thr]=auto_RF;

q10y = thr+10;
ft=fit(x,smooth(rf_data(y==q10y,:)'),'smoothingspline');
xf=linspace(min(x),max(x),10000);

imin=find(ft(xf)<=ul&xf'<bf);
low = xf(imin(end));

imin=find(ft(xf)>=ul&xf'>bf);
if ~isempty(imin)
    high = xf(imin(end));
else
   high = max(x); 
end
q10 = high - low;


end