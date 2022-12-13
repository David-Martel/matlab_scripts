function [bf,thr,monotonicity,ctype,q10,data,x,y,q40,trials]=unitTypingANH(sst,varargin)

%%%%%
% input:
% sst: sst object (receptive field)
%
% output:
% best frequency, threshold
% monotonicity: 1=monotonic, 0=non-monotonic, -1=highly inhibitory,
% -2=inhibitory below SpAc
% ctype: 1=Type I, 3=Type III, 13=Type I/III, 4=type IV-T
%
% ***note: type II (rare) are included by the characteristics of type IV-T,
% need BBN response to separate II from IV-T.
%
% calvin wu, 20-oct-14
% amarins, 1-jan-16: including Q10-dB analysis
%%%%%

bf=[];
thr=[];
monotonicity=[];
ctype=[];
q10=[];
q40=[];

disp('Importing SST...')
trials=find_rf_trial(sst);
x=sst.SortedEpocs('frq1',trials);
x(x==0)=[];    x(x==200)=[];
y=sst.SortedEpocs('lev1',trials);
data=[];
for i = 1:length(x)
    for j = 1:length(y)
        data(j,i) = SpikeRate(sst,[0 0.05],intersect(sst.TrialSelect('frq1',x(i),'lev1',y(j)),trials),'type','S1','norm','rate')-SpikeRate(sst,[0 0.05],intersect(sst.TrialSelect('frq1',x(i),'lev1',y(j)),trials),'type','SW','norm','rate');
    end
end


disp('Determining BF, Threshold and Q10dB ...')

%     if length(x)~=length(data)
%         data(:,1)=[];
%     end

% calculate confidence intervals around the SFR (level = 0)
ul=nanmean(data(1,:))+2*nanstd(data(1,:)); % upper limit
ll=nanmean(data(1,:))-2*nanstd(data(1,:)); % lower limit

datacor=[];
for i=1:length(y)
    for j=1:length(x)
        if data(i,j)>ul
            datacor(i,j)=1;
        elseif data(i,j)<ll
            datacor(i,j)=-1;
        else
            datacor(i,j)=0;
        end
    end
end

frqsel=[];frqselcor=[];
for i=1:length(x)
    frqsel(i)=sum(data(data(:,i)>=0,i));
    frqselcor(i)=sum(datacor(datacor(:,i)>=0,i));
end
ind=find(max(frqsel)==frqsel);
indcor=find(max(frqselcor)==frqselcor);

if length(ind)==1&length(indcor)==1
    bf=x(indcor);
elseif length(ind)==1|length(indcor)==1
    ind2=find(abs(indcor-ind)==min(abs(indcor-ind)));
    if length(ind2)>1
        ind2=ind2(1);
    end
    if length(ind)<length(indcor)
        indcor=indcor(ind2);
        bf=x(indcor);
    else
        ind=ind(ind2);
        bf=x(ind);
    end
else
    if length(ind)<length(indcor)
        indcor=indcor(find(ismember(indcor,ind)));
        if ~isempty(indcor)
            bf=x(indcor);
        else
            bf=NaN;
        end
    elseif length(ind)>length(indcor)
        ind=ind(find(ismember(ind,indcor)));
        if ~isempty(ind)
            bf=x(ind);
        else
            bf=NaN;
        end
    end
end

if ~isempty(bf)
    if length(bf)>1
        bf=x(round(median(ind)));
    end
    
    findthr=datacor(:,find(x==bf));
    thrsel=0;
    for i=1:length(findthr)-3
        if (findthr(i)==1&findthr(i+1)==1&(findthr(i+2)==1|findthr(i+3)==1))...
                |(findthr(i)==1&(findthr(i+1)==1|findthr(i+2)==1)&findthr(i+3)==1)
            thrsel(end+1)=i;
        end
    end
    thrsel(thrsel==0)=[];
    thrsel=min(thrsel);
    
    thr=5*(thrsel-1);
    
    % find Q10 dB
    if thr<=max(y)-10
        z=find(y==(thr+10));
        row=find(datacor(z,:)==1);
        if length(row)<2
            q10=NaN;
        else
            row=sortrows(row);
            while length(row)>2 && row(2)-row(1)>2
                row=row(2:end);
            end
            while length(row)>2 && row(end)-row(end-1)>2
                row=row(1:end-1);
            end
            lb=x(row(1)); ub=x(row(end));
            q10=bf/(ub-lb);
            ub10=ub;
            lb10=lb;
        end
    else
        q10=NaN;
    end
    
    % find Q40 dB
    if thr<=max(y)-40
        z=find(y==(thr+40));
        row=find(datacor(z,:)==1);
        if length(row)<2
            q40=NaN;
        else
            row=sortrows(row);
            while length(row)>2 && row(2)-row(1)>2
                row=row(2:end);
            end
            while length(row)>2 && row(end)-row(end-1)>2
                row=row(1:end-1);
            end
            lb=x(row(1)); ub=x(row(end));
            q40=bf/(ub-lb);
            ub40=ub;
            lb40=lb;
        end
    else
        q40=NaN;
    end
    
else
    bf=NaN;
    thr=NaN;
    q10=NaN;
    q40=NaN;
end

if ~isnan(bf)&~isnan(thr)
    ff1=figure('position',[600 200 500 420]);
    
    subplot(2,2,1) %RF
    pcolor(x,y,datacor);
    set(gca,'xscale','log');
    if ~isempty(bf)&~isempty(thr)&~isnan(bf)&~isnan(thr)
        line([bf bf],get(gca,'ylim'),'linewidth',2,'color','k')
        line(get(gca,'xlim'),[thr thr],'linewidth',2,'color','k')
    end
    
    subplot(2,2,2) %RLF
    rlf=smooth(data(:,find(x==bf)));
    plot(y,rlf)
    line([thr thr],get(gca,'ylim'))
    rlfdiff=diff(rlf(find(y==thr)+1:end));
    if isempty(rlfdiff(rlfdiff<0))
        monotonicity=1;
        title('Monotonic')
    elseif abs(rlfdiff(find(rlfdiff<0)))<abs(mean(rlfdiff))
        monotonicity=1;
        title('Monotonic')
    else
        monotonicity=0;
        title('Non-Monotonic')
        if sum(abs(rlfdiff(rlfdiff<0)))>=sum(abs(rlfdiff(rlfdiff>0)))
            monotonicity=-1;
            title('Inhibitory')
            if min(rlf(find(y==thr)+1:end))<0
                monotonicity=-2;
            end
        end
    end
    
    subplot(2,2,3) %Heatmap
    contour(x,y,data,25,'fill','on');
    set(gca,'xscale','log');
    if ~isempty(bf)&~isempty(thr)&~isnan(bf)&~isnan(thr)
        line([bf bf],get(gca,'ylim'),'linewidth',2,'color','k')
        line(get(gca,'xlim'),[thr thr],'linewidth',2,'color','k')
        if ~isnan(q10)
            line([lb10 ub10],[thr+10 thr+10],'linewidth',2,'color','r')
        end
        if ~isnan(q40)
            line([lb40 ub40],[thr+40 thr+40],'linewidth',2,'color','r')
        end
        
        subplot(2,2,4)
        indthr=find(y==thr+20);
        if ~isempty(indthr)&indthr+4<length(y)
            plot(x,data(indthr,:),'b');hold on
            plot(x,data(1,:),'r')
            hold off
            set(gca,'xscale','log','xlim',[min(x) max(x)]);
            line([bf bf],get(gca,'ylim'),'color','k')
            line(get(gca,'xlim'),[0 0],'color','k')
            
            if thr~=0
                a=min(min(data(indthr:indthr+4,:)));
                c=min(data(1,:));
            else
                a=mean(reshape(data(indthr:indthr+4,:),numel(data(indthr:indthr+4,:)),1));
                c=0;
            end
            
            disp('Determining Cell Type...')
            
            data=[];
            for i = 1:length(x)
                for j = 1:length(y)
                    data(j,i) = SpikeRate(sst,[0 0.05],intersect(sst.TrialSelect('frq1',x(i),'lev1',y(j)),trials),'type','S1','norm','rate');
                end
            end
            if length(find(data(1,:)==0))>=round(length(data(1,:))/2)&nanmean(data(1,:))<1
                title(sprintf('%s %.1f','Tyle I/III',nanmean(data(1,:))))
                ctype=13;
                if monotonicity==-1
                    title('Tyle IV-T')
                    ctype=4;
                end
            elseif a<=c
                title('Tyle III')
                ctype=3;
            elseif monotonicity==1
                title('Type I')
                ctype=1;
            elseif monotonicity==-1&thr<60
                title('Type IV-T')
                ctype=4;
            else
                ctype=NaN;
                
            end
            
            
            
        else
            title('Threshold too high')
        end
        
    end
    if isempty(bf)
        bf=NaN;
    end
    if isempty(thr)
        thr=NaN;
    end
    if isempty(monotonicity)
        monotonicity=NaN;
    end
    if isempty(ctype)
        ctype=NaN;
    end
    
    ok = questdlg('BF/Threshold selection', ...
        'User input', ...
        'Use current','Use previous','Select again','Use current');
    %%
    if strcmp(ok,'Use previous')&nargin==3
        close(ff1);
        ff1=figure('position',[600 200 500 420]);
        subplot(2,2,1) %RF
        pcolor(x,y,datacor);
        set(gca,'xscale','log');
        bf=varargin{1};
        thr=varargin{2};
        
        
    elseif strcmp(ok,'Select again')
        
        instr=input('Input BF (Hz) and threshold (dB), separated by "/" : ','s');
        while isempty(strfind(instr,'/'))
            instr=input('Input BF (Hz) and threshold (dB), separated by "/" : ','s');
        end
        ss=strfind(instr,'/');
        bf=str2double(instr(1:ss-1));
        thr=str2double(instr(ss+1:end));
        
        
        bf = x(x==min(abs(x-bf)));
        thr = y(y==min(abs(y-thr)));
        
        
    end
    
    
    
    
end


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



