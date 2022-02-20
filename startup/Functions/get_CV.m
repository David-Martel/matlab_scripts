function [cv_winter cv_young bin fsl fisi] = get_CV(ts_cell,binsize)
%
%
%

%% calculate fsl (Chase & Young 2007)

tr = length(ts_cell);
ts_col=sort(cat(1,ts_cell{1:tr}));

spont=sum(ts_col<0.1)./tr./0.1;
ts_tone=ts_col(ts_col>=0.1&ts_col<0.15);

pprob=[];
for j=2:length(ts_tone)
   lambda=tr*spont*(ts_tone(j)-ts_tone(1));
   pprob(j-1)=poisspdf(j,lambda);
end
[~,im]=min(abs(pprob-1e-6));
fsl=ts_tone(im);

% clf
% subplot(3,1,1)
% plot(ts_col,1,'+')
% xlim([0.1 0.2])
% 
% subplot(3,1,2)
% plot(ts_tone(1:end-1),pprob);hold on
% xlim([0.1 0.2]);set(gca,'yscale','log');
% plot(get(gca,'xlim'),[1 1]*1e-6,':')
% ylim([10e-8 1])
% 
% subplot(3,1,3)
% bin=0:0.0001:0.2;
% plot(bin(1:end-1),histcounts(ts_col,bin));hold on
% plot([fsl fsl],get(gca,'ylim'))
% xlim([0.1 0.2])


%% calculate fisi
fisi=NaN(tr,1);
for i=1:tr
   tspt=ts_cell{i};
   if length(tspt)>1
       if tspt(1)>fsl-0.001&tspt(1)<fsl+0.001
           fisi(i)=tspt(2)-tspt(1);
       end
   end
end
fisi=nanmean(fisi);


%% calculate CV_isi

if ~isempty(fsl)

bin=fsl:binsize:0.2;

uall=NaN(tr,length(bin)-1);
uall_trad=NaN(tr,length(bin)-1);
for j=1:tr
    ts=ts_cell{j};
    if ~isempty(ts)
        ts(ts<fsl)=[];
    end
    if length(ts)>2
    s = histcounts(ts,bin);
    u = zeros(size(s));
    fs=find(s==1);
    ds=diff(ts);
    for i=1:length(fs)-1
        u(fs(i):fs(i+1)-1)=ds(i);
    end

    u(u==0)=NaN;
    uall(j,:)=u;
    
    try uall_trad(j,fs(1:end-1))=diff(ts); end
    end
end

cv_winter = nanstd(uall,1)./nanmean(uall,1);
cv_young = nanstd(uall_trad,1)./nanmean(uall_trad,1);

bin=bin(1:end-1);
else
cv_winter=NaN;  cv_young=NaN;  bin=NaN; fsl=NaN;    
end



end