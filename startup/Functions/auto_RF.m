function [bf,thr] = auto_RF(x,y,rf_data)


x_dimension = find(size(rf_data)==length(x));
if x_dimension~=2
    rf_data=transpose(rf_data);
end

try
    thr = get_thr(x,y,rf_data);
catch
    thr=NaN;
end
try
    bf = get_bf(x,y,rf_data,thr);
catch
    bf=NaN;
end

if ~isnan(bf)
    thr = correct_thr(x,y,rf_data,bf);
end


end

function thr = get_thr(x,y,rf_data)


x_auc = rms(rf_data,2);
crit=0.1;
x_auc_fit=fit(y,normalize01(smooth(x_auc')),'smoothingspline');
xint=linspace(min(y),max(y),10000);
yint=x_auc_fit(xint);
[~,imin]=min(abs(yint-crit));
thr=xint(imin);

end

function bf = get_bf(x,y,rf_data,thr)

[~,imin]=min(abs(y-thr));
ft_bf = fit(x,smooth(sum(rf_data(imin:imin+2,:))),'smoothingspline');
xint=linspace(min(x),max(x),10000);
[~,imax]=max(ft_bf(xint));
bf = xint(imax);

end

function thr = correct_thr(x,y,rf_data,bf)

    bf_ind = find(abs(x-bf) == min(abs(x-bf)));
    if bf_ind>1&bf_ind<length(y)
       bf_ind = (bf_ind-1) : 1 : (bf_ind+1);
    end
    rlf_bf = rf_data(:,mean(bf_ind,2));
    x_fit=fit(y,normalize01(smooth(rlf_bf')),'smoothingspline');
    xint=linspace(min(y),max(y),10000);
    yint=x_fit(xint);
	crit=0.1;
    [~,imin]=min(abs(yint-crit));
    thr=xint(imin);
    
end