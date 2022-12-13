%% Get RF
clc;clear
fname='CW79a1';
f_dir = fullfile('F:\sorting',fname);
% f_dir = fullfile(pwd,'sst_mat',fname);

unit_sp=get_sorted_sst(f_dir);
unit_sp(unit_sp.unit==0,:)=[];
disp('sst loaded')

ncol_mat=NaN(length(unit_sp),2);
datacor=cell(length(unit_sp),1);
%
tloc=1;
bloc=1;
for m=1:length(unit_sp)
    
    sst=unit_sp.sst{m};
    y=sst.SortedEpocs('lev1',sst.TrialSelect('tind',tloc,'bind',bloc,'find',1));
    x=sst.SortedEpocs('frq1',sst.TrialSelect('tind',tloc,'bind',bloc,'find',1));
    
    x(x==200)=[]; %x(x>24000)=[];
    data=[];
    for i = 1:length(x)
        for j = 1:length(y)
            idx=sst.TrialSelect('frq1',x(i),'lev1',y(j),'tind',tloc,'bind',bloc,'find',1);
            data(j,i)=SpikeRate(sst,[0 0.05],idx,'type','S1','norm','rate')-SpikeRate(sst,[0 0.05],idx,'type','SW','norm','rate');
        end
    end
    
    % 	[ncol_mat(m,1),ncol_mat(m,2)]=auto_RF(x,y,data);
    [ncol_mat(m,1),ncol_mat(m,2),~,~,datacor{m}]=autoCellType(x,y,data);
    disp(sprintf('%d/%d',m,length(unit_sp)))
end
unit_sp=[unit_sp, mat2dataset(ncol_mat,'varnames',{'bf','thr'})];
idx_del = isnan(unit_sp.bf)&isnan(unit_sp.thr);
unit_sp(idx_del,:)=[]
datacor(idx_del)=[];

%% Plot RF
clf
for m=1:length(unit_sp)
    bf=unit_sp.bf(m);
    thr=unit_sp.thr(m);
    sp_dimension=numSubplots(length(unit_sp));
    subplot(sp_dimension(1),sp_dimension(2),m);
    xlim([min(x) max(x)]);
    ylim([min(y) max(y)]);
    box on
    hold(gca,'all');
    h=pcolor(x,y,datacor{m});
    set(h,'edgecolor','none')
    set(gca,'xscale','log','xtick',[bf],'xticklabel',num2cell(round(bf/100)./10),...
        'ytick',[thr],'yticklabel',num2cell(round(thr)),'fontsize',6);
    line([bf bf],get(gca,'ylim'),'color',[0.5 0.5 0.5],'linewidth',1);
    line(get(gca,'xlim'),[thr thr],'color',[0.5 0.5 0.5],'linewidth',1);
    title(sprintf('%d-%d (%d)',unit_sp.ch(m),unit_sp.unit(m),m),'fontsize',6)
    drawnow;
end


%% select
index=select_subplot(length(unit_sp));
unit_sp(index,:)=[]
datacor(index)=[];

%%
% unit_sp=[unit_sp,mat2dataset(probe_map(unit_sp.ch),'varnames','z')]

%% MANUALLY CORRECT BF

ff=select_subplot(length(unit_sp))
for n=1:length(ff)
    clf
    set(gcf,'position',[100 200 400 400]);
    m=ff(n);
    sst=unit_sp.sst{m};
    for s=1:3
        subplot(3,1,s)
        if s==1
            x=sst.SortedEpocs('frq1',sst.TrialSelect('bind',1,'find',1));
            y=sst.SortedEpocs('lev1',sst.TrialSelect('bind',1,'find',1));
            x(x==200)=[];
            data=[];
            for i = 1:length(x)
                for j = 1:length(y)
                    trials=sst.TrialSelect('frq1',x(i),'lev1',y(j),'bind',1,'find',1);
                    data(j,i)=SpikeRate(sst,[0 0.05],trials,'type','S1','norm','rate')-SpikeRate(sst,[0 0.05],trials,'type','SW','norm','rate');
                end
            end
        end
        if s==3
            ul=nanmean(data(1,:))+2*nanstd(data(1,:));
            ll=nanmean(data(1,:))-2*nanstd(data(1,:));
            
            data_sig=[];
            for i=1:length(y)
                for j=1:length(x)
                    if data(i,j)>ul
                        data_sig(i,j)=1;
                    elseif data(i,j)<ll
                        data_sig(i,j)=-1;
                    else
                        data_sig(i,j)=0;
                    end
                end
            end
        end
        xlim([min(x) max(x)]);
        ylim([min(y) max(y)]);
        box on
        hold(gca,'all');
        if s==1
            h=pcolor(x,y,data);
        elseif s==2
            [data_t,zt,zl]=rf_logz(data,3);
            h=pcolor(x,y,data_t);
        elseif s==3
            h=pcolor(x,y,data_sig);
        end
        set(h,'edgecolor','none')
        set(gca,'xscale','log','xtick',[unit_sp.bf(m,1)],'xticklabel',num2cell(unit_sp.bf(m,1)/1000),...
            'ytick',[unit_sp.thr(m,1)],'yticklabel',num2cell(unit_sp.thr(m,1)),'fontsize',6);
        
        line([unit_sp.bf(m,1) unit_sp.bf(m,1)],get(gca,'ylim'),'color',[0.5 0.5 0.5],'linewidth',1);
        line(get(gca,'xlim'),[unit_sp.thr(m,1) unit_sp.thr(m,1)],'color',[0.5 0.5 0.5],'linewidth',1);
        
        title(sprintf('%d-%d',unit_sp.ch(m),unit_sp.unit(m)),'fontsize',6)
        if s==3
            disp('user input requested..');
            
            [bf thr]=ginput(1);
            xfind=abs(x-bf);
            bf=x(xfind==min(xfind));
            yfind=abs(y-thr);
            thr=y(yfind==min(yfind));
            gtext(sprintf('%4.0f%s%2.0f',bf,'/',thr),'fontsize',8,'color','r')
            line([bf bf],get(gca,'ylim'),'color',[0.5 0.5 0.5],'linewidth',1);
            line(get(gca,'xlim'),[thr thr],'color',[0.5 0.5 0.5],'linewidth',1);
            unit_sp.bf(m)=bf;
            unit_sp.thr(m)=thr;
            disp('continuing..')
            
        end
        drawnow;
    end
end

disp('done')
close all

%% load unit_sp and sst
fname='CW75';
load(fullfile(pwd,'sst_mat',[fname '_index']));
sst=cell(length(unit_sp),1);
for u=1:length(unit_sp)
    sst{u}=get_sorted_sst(fullfile('U:\Calvin\Analysis\sst_mat',fname),unit_sp.ch(u),unit_sp.unit(u));
    fprintf([num2str(u) '..'])
end
unit_sp=[unit_sp,table2dataset(table(sst))]

%% PSTH typing
close all
clear resultList
clc;
tloc=1;
bloc=3;
for m=1:length(unit_sp)
    clc
    clf
    m
    sst=unit_sp.sst{m};
    bf=unit_sp.bf(m);
    thr=unit_sp.thr(m);
    
    colormap(jet);
    set(gcf,'position',[100 100 600 400])

    titlestr=sprintf('%d-%d',unit_sp.ch(m),unit_sp.unit(m));
    resultList{m}=unitTypingGUI(sst,bf,thr,tloc,bloc,titlestr);
    
end

if ismember('psth',unit_sp.Properties.VarNames)
    unit_sp.psth=[];
end
unit_sp=[unit_sp,mat2dataset(resultList','varnames','psth')]

%% SAVE
a=whos('unit_sp');
s = input(sprintf('%s_index is ~%.0f mb, save/trim/cancel? (s/t/n)',fullfile(fname),a.bytes./1000000),'s');
if strcmp(s,'s')
    tic
    disp('Saving...')
    save(fullfile(pwd,'sst_mat',[fname '_index.mat']),'unit_sp')
    disp(sprintf('Saved as %s',fullfile(pwd,'sst_mat',[fname '_index.mat'])))
    toc
elseif strcmp(s,'n')
    disp('not saved');
elseif strcmp(s,'t')
    unit_sp.sst=[];
    tic
    disp('Saving...')
    save(fullfile(pwd,'sst_mat',[fname '_index.mat']),'unit_sp')
    disp(sprintf('Saved as %s',fullfile(pwd,'sst_mat',[fname '_index.mat'])))
    toc
end

