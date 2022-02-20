clf;
clc
% clearvars -except sst_blocks
sst=sst_blocks{2,2}{14};

trials=sst.TrialSelect();
ls=sst.GetSpikes(trials,'SW');
lm=0;
um=0.2;
binx=0.001;
spac=SpikeRate(sst,[0 0.1],[],'type','SW','norm','count')./0.1;

x=lm:binx:um;
y=histc(ls,x)./(length(ls).*binx);
x=reshape(x,length(x),1);
y=reshape(y,length(y),1);
subplot(2,2,1)
bar(x,y,'k'); xlabel('PST (s)'); ylabel('Sp/s')
coef=0.001/binx;
set(gca,'ytick',get(gca,'ytick'),...
            'xlim',[lm um],'yticklabel',num2cell(get(gca,'ytick')/coef))
        
subplot(2,2,3)
ls2=[];
count=0;
for i=1:length(trials)
    ls=sst.GetSpikes(trials(i),'SW');
    ls=ls(ls>lm&ls<um);
    if ~isempty(ls)
        ls2=[ls2;ls];
        plot(ls,i,'k.');hold on
    end
end
subplot(2,2,2)
        plot(ls2,1,'.');hold on
%
pd_fsl=[];
ls2=sort(ls2);
for m=0:length(ls2)-1
    pd_fsl(m+1)=poisspdf(m,spac*ls2(m+1));
end

subplot(2,2,4)
plot(ls2,pd_fsl);hold on
set(gca,'yscale','log')
ylim([10^-12 1])
xlim([lm um])
line(get(gca,'xlim'),[10^-6 10^-6],'linestyle',':')

fx=find(pd_fsl<10^-6&ls2'>0.1); 
fsl=ls2(fx(1));

fisi=[];
for n=1:length(trials)
    ls=sst.GetSpikes(trials(n),'SW');
    ls=ls(ls>lm&ls<um);
    if ~isempty(ls)
        fx2=find(ls>fsl);
        if ~isempty(fx2)&length(fx2)>=2
            fisi=[fisi,ls(fx2(2))-ls(fx2(1))];
        end
    end
end
fisi=mean(fisi);

subplot(2,2,1)
hold on;
line([fsl fsl],get(gca,'ylim'))

subplot(2,2,2)
hold on;
line([fsl fsl],get(gca,'ylim'))

subplot(2,2,3)
hold on;
line([fsl fsl],get(gca,'ylim'))
% line([fsl+0.0005 fsl+0.0005],get(gca,'ylim'),'color','r')
fsl=fsl-0.1
fisi
    