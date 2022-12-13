function [log_z,tick,label] = rf_logz(z,nTicks)


log_z = log10(z-min(min(z)));


z_scale = sort(reshape(log_z,numel(log_z),1));
z_scale(isinf(z_scale))=[];

tick = linspace(min(z_scale),max(z_scale),nTicks);
label = num2cell(round(10.^(tick)+min(tick)));
    

end