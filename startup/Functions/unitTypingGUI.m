function [unittype,bf,thr] = unitTypingGUI(sst,varargin)
%
%
%
%
% bloc=1;
% tloc=1;
%%
clf
set(gcf,'position',[200 300 600 200],'Name','Draw box on RF to plot PSTH, click on BF-THR to select')

bf=200;
thr=0;

trsel=find_rf_trial(sst);

frqlist=sst.SortedEpocs('frq1',trsel);
levlist=sst.SortedEpocs('lev1',trsel);
frqidx=find(abs(frqlist-bf)==min(abs(frqlist-bf)));

try
    fsel=[frqlist(frqidx-1) frqlist(frqidx) frqlist(frqidx+1)];
catch
    fsel=bf;
end

subplot(1,2,2)
LocalSpikes=sst.GetSpikes(trsel,'S1');
x=-0.05:0.001:0.1;
y=histc(LocalSpikes,x)./(length(trsel).*0.001);
bar(x,y,'k');
hold on;
xlim([-0.05 0.1]);
box off;
xlabel('Time (s)');ylabel('Spike Rate (1/s)');
set(gca,'fontsize',8)

subplot(1,2,1)
y=sst.SortedEpocs('lev1',trsel);
x=sst.SortedEpocs('frq1',trsel);

x(x==200)=[];
data=[];
for i = 1:length(x)
    for j = 1:length(y)
        idx=intersect(sst.TrialSelect('frq1',x(i),'lev1',y(j)),trsel);
        data(j,i)=SpikeRate(sst,[0 0.05],idx,'type','S1','norm','rate')-SpikeRate(sst,[0 0.05],idx,'type','SW','norm','rate');
    end
end

unittype=NaN;
bf=NaN;
thr=NaN;

if sum(sum(data))~=sum(data(1,:))
    [data_t,zt,zl]=rf_logz(data,3);
    set(gca,'Layer','top',...
        'xscale','log');

xlim([min(x) max(x)]);
ylim([min(y) max(y)]);
box on
hold(gca,'all');
h=pcolor(x,y,data_t);
set(h,'edgecolor','none')
xlabel('Frequency (kHz)');
ylabel('Intensity (dB SPL)');
h=colorbar;
delete(h);
line([bf bf],get(gca,'ylim'),'color',[0.5 0.5 0.5],'linewidth',1);
line(get(gca,'xlim'),[thr thr],'color',[0.5 0.5 0.5],'linewidth',1);
set(gca,'fontsize',8)
if ~isempty(varargin)
    title(varargin{1},'fontsize',8)
end
drawnow;

h=imrect;

k=0;
hr=[]; s2=[];

while ~k
    pos = getPosition(h);
    if pos(3)==0&pos(4)==0
        k=1;
        bf=pos(1);
        thr=pos(2);
    else
        delete(s2)
        delete(h)
        delete(hr)
        hr=rectangle('position',pos,'edgecolor',[0.5 0.5 0.5]);
        fsel=frqlist(frqlist>=pos(1)&frqlist<=(pos(1)+pos(3)));
        lsel=levlist(levlist>=pos(2)&levlist<=(pos(2)+pos(4)));
        s2=subplot(1,2,2);
        LocalSpikes=sst.GetSpikes(intersect(sst.TrialSelect('frq1',fsel,'lev1',lsel),trsel),'S1');
        x=-0.05:0.001:0.1;
        y=histc(LocalSpikes,x)./(length(intersect(sst.TrialSelect('frq1',fsel,'lev1',lsel),trsel)).*0.001);
        bar(x,y,'k');
        hold on;
        xlim([-0.05 0.1]);
        box off;
        xlabel('Time (s)');ylabel('Spike Rate (1/s)');
        set(gca,'fontsize',8)
        subplot(1,2,1)
        delete(h)
        h=imrect;
    end
end



TypeList={'P/B','B','PL','PLN','Cs','Ct','O','Ol','Oc','Oi','Og','CX','LF','UN','NR'};
[sel,v] = listdlg('PromptString','PSTH Type:',...
    'SelectionMode','single',...
    'ListString',TypeList);
if v==1
    unittype=TypeList{sel};
elseif v==0
    unittype='Check';
end
end
close all


end



function trsel=find_rf_trial(sst)
%%

trsel=[];
if ismember('tind',sst.Epocs.Values.Properties.VarNames)
    [u,b,c]=unique(sst.Epocs.Values(:,{'tind','bind'}));
	for i=1:max(c)
        u.frq(i,1)=length(unique(sst.Epocs.Values.frq1(c==i)));
        u.eamp(i,1)=max(sst.Epocs.Values.eamp(c==i));
    end
    im=find(u.frq>10&u.eamp==0);
    vn = u.Properties.VarNames;
    vnv = double(u(im,:));
    trsel = sst.TrialSelect(vn{1},vnv(1,1),vn{2},vnv(1,2));
elseif ismember('bind',sst.Epocs.Values.Properties.VarNames)
    [u,b,c]=unique(sst.Epocs.Values.bind);
    for i=1:max(c)
        u(i,2)=length(unique(sst.Epocs.Values.frq1(c==i)));
        u(i,3)=nanmax(sst.Epocs.Values.eamp(c==i));
    end
    im=find(u(:,2)>10&(u(:,3)==0|isnan(u(:,3))),1);
    trsel = sst.TrialSelect('bind',im);
else
    trsel = sst.TrialSelect();
end

end

