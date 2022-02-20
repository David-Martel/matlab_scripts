function [xout,yout]=corline(xin,yin,zero)
% xin,yin: input matrices x and y
% xout,yout: linspace matrices for regression line
% zero=1: pass through origin

if zero==1
    po=polyfitZero(xin,yin,1);
else
    po=polyfit(xin,yin,1);
end


xout=linspace(min(xin),max(xin));
yout=polyval(po,xout);

end

