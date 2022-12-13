function [UnitType,bf,thr,q10,q40,monotonicity,p20,sus20,fsl20,CV20,p50,sus50,fsl50,CV50]=unitTypingVCN(sst)

% This script will type the units recorded from the VCN as onsets as
% defined by Ingham et al. 2006 (Brain Research), On-I, On-C, and On-L,
% choppers as defined by Young et al. 1988 (J Neurophysiol), Ch-S and Ch-T, and
% primary-like as defined by Young et al. 1988 (J Neurophysiol). 

% The program will plot all the features in one figure and make a
% prediction on which unit it is. Then it will put all information in a 
% table called unit_AllInfo, it will also make a table that only contains 
% the unit types. 

% By: Amarins, April 2016
% Revision: June, 2016: to incorporate the superblocks (AS)
% Revision: April, 2018 by Calvin: streamline and incorporate into master
% unit sorting program



%%
% get bf, q10, threshold, etc.
[bf,thr,monotonicity,ctype,q10,data,x,y,q40,trselRF]=unitTypingANH(sst);


%%
if (sum(sum(data))~=sum(data(1,:)))&~isnan(bf)&~isnan(thr)
    ok=questdlg('Select this unit? (Warning: Bad unit may cause the program to crash)', ...
        'User input?', ...
        'Yes','No','Yes');
else
    ok='No';
end
if strcmp(ok,'Yes')
%% 
    % prepare the figure
    FigHandle = figure('Position', [100, 70, 1049, 895]);
    ha = axes('Position',[0.05 0.95 0.9 0.05],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized','clipping','off');
    text(0.5,1,sprintf('\b Unit type of channel %d, unit %d',sst.Channel,sst.Unit),'HorizontalAlignment','center','VerticalAlignment','top','Fontsize',18,'FontWeight','bold')
    hold on;
    
    
    % ----- plot the RF info ------
    
    subplot('Position',[0.05 0.7 0.2 0.2])
    ah = pcolor(x,y,data);
    colormap;
    axis([min(x) max(x) min(y) max(y)]);
    ax=gca;
    set(ax,'XScale','log')
    title(sprintf('BF = %d Hz, thr = %d dB SPL',bf,thr))
    xlabel('Frequency (Hz)'); ylabel('Intensity (dB SPL)');
    hold on;
    
%  
    % ----- plot the RLF info -----
    
    % get RLF tone from the receptive field
    BFloc=find(x==bf); % find where that BF is in the freq vector
    rlfT=[y,data(:,BFloc)]; % get the RLF of tone
    

    % find RLF noise trial
            trsel=[];
            [u,~,c]=unique(sst.Epocs.Values(:,{'bind','find'}));
            d=[];
            for i=1:max(c)
                d(i,1)=length(unique(sst.Epocs.Values.frq1(c==i)));
                d(i,2)=sum(sst.Epocs.Values.frq1(c==i)==200&sst.Epocs.Values.lev1(c==i)>0);
                d(i,3)=nanmax(sst.Epocs.Values.eamp(c==i));
            end
            loc=find(d(:,1)==1&d(:,2)>0&d(:,3)==0,1);


if ~isempty(loc) 
    trsel = sst.TrialSelect('bind',u.bind(loc),'find',u.find(loc));
    all_levels=SortedEpocs(sst,'lev1',trsel);
    for k=1:length(all_levels)
        rlf(k,1)=SpikeRate(sst,[0 0.05],intersect(TrialSelect(sst,'lev1',all_levels(k)),trsel),'type','S1','norm','rate');
    end
    rlfN=[all_levels,rlf];
end
    % plot both in the same subplot
    subplot('Position',[0.05 0.4 0.2 0.2])
    plot(rlfT(:,1),smooth(rlfT(:,2)),'r','LineWidth',3);
    if ~isempty(loc)
        hold on; plot(rlfN(:,1),smooth(rlfN(:,2)),'k','LineWidth',3);
    end
    legend({'RLF BF-tone','RLF noise'},'Location','northwest')
    legend('boxoff')
    title('Rate-level functions')
    xlabel('Intensity (dB SPL)'); ylabel('Firing rate (sp/sec)');
    
% 
    % find PSTH trials
            trsel=[];
            [u,~,c]=unique(sst.Epocs.Values(:,{'bind','find'}));
            d=[];
            for i=1:max(c)
                d(i,1)=length(unique(sst.Epocs.Values.frq1(c==i)));
                d(i,2)=length(unique(sst.Epocs.Values.lev1(c==i)));
                d(i,3)=sum(sst.Epocs.Values.lev1(c==i)>0&sst.Epocs.Values.frq1(c==i)~=200);
                d(i,4)=nanmax(sst.Epocs.Values.eamp(c==i));
            end
loc=find(d(:,1)==1&d(:,2)==1&d(:,3)>0&d(:,4)==0,1);

if ~isempty(loc)
bInd=u.bind(loc);
fPSTH20=u.find(loc);
end


%
warning('off','all')
    % ----- plot the PSTHs -----
    
    % PSTH 20 dB SL - data
    if ~isempty(loc) % when there is a +20 dB defined
%%
        trials20=sst.TrialSelect('bind',bInd,'find',fPSTH20,'tind',1);
        ls=sst.GetSpikes(trials20,'S1');
        frq20=sst.Epocs.Values.frq1(trials20(1));
        lev20=sst.Epocs.Values.lev1(trials20(1)); % get the frequency and intensity from sst
        stimDur=sst.Epocs.TSOff.s1ig(trials20(1))-sst.Epocs.TSOn.s1ig(trials20(1));
        
    else % when there is no +20 dB defined, select that from receptive field
        %%
        ylev=find(y==thr+20);
        if isempty(ylev) || ylev==length(y)
            ylev=length(y);
            ylevs=[length(y) length(y)-1];
        else
            ylevs=[ylev-1 ylev ylev+1];
        end
        RFlevs=y(ylevs);
        
        trials20=intersect(sst.TrialSelect('frq1',x(BFloc-1:BFloc+1),'lev1',RFlevs),trselRF);
        ls=sst.GetSpikes(trials20,'S1');
        frq20=x(BFloc); lev20=y(ylev);
        stimDur=sst.Epocs.TSOff.s1ig(trials20(1))-sst.Epocs.TSOn.s1ig(trials20(1));
    end
    bw=0.0005; % define the binwidth
    PSTHend=stimDur+0.03;
    ls=ls(ls>0&ls<PSTHend); % get only the spikes from stim onset to 80 sec after
    [N,edges]=histcounts(ls,round(PSTHend/bw));
    Nrate=(N./0.0005); Nrate=Nrate/length(trials20); % convert spike count to spike rate
    edgesRate=edges(2:end)-((edges(2)-edges(1))/2); % convert edges to medium points
    p20=max(Nrate); sus20=mean(Nrate((0.015/bw):round(stimDur/bw))); % peak and sustained rate (from 15ms after onset to offset stimulus)
    [fsl20,~,~,~]=getTiming2(sst,trials20);
    fsl20=(fsl20-0.1)*1000;
    
    % PSTH 20 dB SL - figure
    subplot('Position',[0.35 0.7 0.2 0.2])
    bar(edgesRate.*1000,Nrate,'k')
    xlabel('time rel. auditory onset (ms)'); ylabel('spike rate (sp/s)'); xlim([0 PSTHend*1000]);
    title(sprintf('PSTH %.3f kHz, %d dB SL',frq20/1000,lev20-thr))
    % insert text in the figure
    xloc=(max(edgesRate)*1000)*0.3; yax=ylim; yloc=yax(2)*0.8; % define location
    fprintf('Sust rate = %d sp/s\n[peak\\sust rate] = %.2f\nFSL = %.1f\n\n',round(sus20),p20/sus20,fsl20);
    
    % calculate and plot the mut and sigt for PSTH 20 dB SL
    bw2=0.0002; % define binwidth for CV vector, typically 0.2 ms
    stTime=0.012; endTime=0.02; % define start and endTime to get eventual CV
    [CV,CVvec,xt,mut,sigt]=getCVvec(sst,trials20,bw2,stTime,endTime);
    subplot('Position',[0.35 0.4 0.2 0.2])
    if ~isnan(xt)
        plot((xt(2:end).*1000),mut.*1000,'r','Linewidth',1)
        hold on
        plot((xt(2:end).*1000),sigt.*1000,'b','Linewidth',1)
        xlabel('time rel. aud onset (ms)'); ylabel('msec');
        title(sprintf('CV = %.2g',CV))
        xlim([0 80])
    end
    
    % calculate and plot the CV for PSTH 20 dB SL
    subplot('Position',[0.35 0.1 0.2 0.2])
    if ~isnan(xt)
        plot((xt(2:end).*1000),CVvec,'k','Linewidth',1)
        xlabel('time rel. aud onset (ms)'); ylabel('CV');
        title(sprintf('CV = %.2g',CV))
        xlim([0 80])
    end
    CV20=CV;
    
    %
    % PSTH 50 dB SL - data
    
        ylev=find(y==thr+20);
        if isempty(ylev) || ylev==length(y)
            ylev=length(y);
            ylevs=[length(y) length(y)-1];
        else
            ylevs=[ylev-1 ylev ylev+1];
        end
        RFlevs=y(ylevs);

        trials50=intersect(sst.TrialSelect('frq1',x(BFloc-1:BFloc+1),'lev1',RFlevs),trselRF);
        ls=sst.GetSpikes(trials50,'S1');
        frq50=x(BFloc); lev50=y(ylev);
        stimDur=sst.Epocs.TSOff.s1ig(trials50(1))-sst.Epocs.TSOn.s1ig(trials50(1));

        bw=0.0005; % define the binwidth
    PSTHend=stimDur+0.03;
    ls=ls(ls>0&ls<PSTHend); % get only the spikes from stim onset to 80 sec after
    [N,edges]=histcounts(ls,round(PSTHend/bw));
    Nrate=(N./0.0005); Nrate=Nrate/length(trials50); % convert spike count to spike rate
    edgesRate=edges(2:end)-((edges(2)-edges(1))/2); % convert edges to medium points
    p50=max(Nrate); sus50=mean(Nrate((0.015/bw):round(stimDur/bw))); % peak and sustained rate (from 15ms after onset to offset stimulus)
    [fsl50,~,~,~]=getTiming2(sst,trials50);
    fsl50=(fsl50-0.1)*1000;
    
    % PSTH 50 dB SL - figure
    subplot('Position',[0.65 0.7 0.2 0.2])
    bar(edgesRate.*1000,Nrate,'k')
    xlabel('time rel. auditory onset (ms)'); ylabel('spike rate (sp/s)'); xlim([0 PSTHend*1000]);
    title(sprintf('PSTH %.3f kHz, %d dB SL',frq50/1000,lev50-thr))
    % insert text in the figure
    xloc=(max(edgesRate)*1000)*0.3; yax=ylim; yloc=yax(2)*0.8; % define location
    fprintf('Sust rate = %d sp/s\n[peak\\sust rate] = %.2f\nFSL = %.1f\n\n',round(sus50),p50/sus50,fsl50);
    
    % calculate and plot the mut and sigt for PSTH 50 dB SL
    bw2=0.0002; % define binwidth for CV vector, typically 0.2 ms
    stTime=0.012; endTime=0.02; % define start and endTime to get eventual CV
    [CV,CVvec,xt,mut,sigt]=getCVvec(sst,trials50,bw2,stTime,endTime);
    subplot('Position',[0.65 0.4 0.2 0.2])
    if ~isnan(xt)
        plot((xt(2:end).*1000),mut.*1000,'r','Linewidth',1)
        hold on
        plot((xt(2:end).*1000),sigt.*1000,'b','Linewidth',1)
        xlabel('time rel. aud onset (ms)'); ylabel('msec');
        title(sprintf('CV = %d',CV))
        xlim([0 80])
    end
    
    % calculate and plot the CV for PSTH 50 dB SL
    subplot('Position',[0.65 0.1 0.2 0.2])
    if ~isnan(xt)
        plot((xt(2:end).*1000),CVvec,'k','Linewidth',1)
        xlabel('time rel. aud onset (ms)'); ylabel('CV');
        title(sprintf('CV = %d',CV))
        xlim([0 80])
    end
    CV50=CV;
    
    %
    % ----- determine the unit type -----
    
    % Onsets when the peak-to-sustained ratio is higher than 10 for 20 and 50 dB SL
    if (p20/sus20)>10 && (p50/sus50)>10
        
        % On-I when there is no/low sustained rate at both 20 and 50 dB SL
        if sus20<10 && sus50<10
            textT=sprintf('On-I unit, because peak-to-sustained>10\n and low sustained rates');
            certain=2; % definitely certain, only confirm
            type=21;
        else
            textT=sprintf('This is an onset unit. On-C when you\n see a second peak at 50 dB SL, otherwise On-L');
            type=20;
            certain=1; % choose between two options
        end
        
        % Choppers when CV less than or equal to 0.3
    elseif CV50 <=0.5
        if CV50 <=0.35
            textT=sprintf('Chopper sustained unit, because CV at\n 50 dB SL less than or equal to 0.35');
            type=32;
            certain=2; % definitely certain, only confirm
        else
            textT=sprintf('This might be a transient chopper unit,\n if the CV increases between 0.35-0.5 over time');
            type=30;
            certain=0; % anything still possible, check
        end
        
        % Low Frequency units when BF less than or equal to 500 Hz
    elseif bf <= 500
        textT=sprintf('Low frequency unit, because the BF is\n less than or equal to 500 Hz');
        type=41;
        certain=2;
        
        % Primary-like often have high sustained rates at 50 dB SL
    elseif sus50>100
        textT=sprintf('Primary-like unit, PL-N when you see a\n notch after first onset response');
        type=10;
    else
        textT=sprintf('It is not certain what unit this is,\n please study carefully');
    end
    
    
    % ----- Make a text box with information and unit selection -----
    
    RFstring=sprintf('The monotonicity is %d, the ctype is %d',monotonicity, ctype);
    ha2 = axes('Position',[0.05 0.1 0.2 0.2],'Xlim',[0 1],'Ylim',[0 1],'Visible','off','Units','normalized','clipping','off');
    text(0,0.8,RFstring,'HorizontalAlignment','left','VerticalAlignment','middle','Fontsize',10)
    hold on;
    
    ha3 = axes('Position',[0.05 0.05 0.2 0.2],'Xlim',[0 1],'Ylim',[0 1],'Visible','off','Units','normalized','clipping','off');
    text(0,0.8,textT,'HorizontalAlignment','left','VerticalAlignment','middle','Fontsize',10)
    hold on;

TypeList={'P/B','B','PL','PLN','Cs','Ct','O','Ol','Oc','Oi','Og','CX','LF','UN','NR'};
[sel,v] = listdlg('PromptString','PSTH Type:',...
    'SelectionMode','single',...
    'ListString',TypeList);
if v==1
    UnitType=TypeList{sel};
elseif v==0
    UnitType='Check';
end

    Typestring=sprintf('This unit was classified as %s',UnitType);
    ha4 = axes('Position',[0.05 0.01 0.2 0.2],'Xlim',[0 1],'Ylim',[0 1],'Visible','off','Units','normalized','clipping','off');
    text(0,0.8,Typestring,'HorizontalAlignment','left','VerticalAlignment','middle','Fontsize',10)
    hold on;
   
else
    %% if unit not selected
    UnitType='Check';
    p20=NaN; sus20=NaN; fsl20=NaN; CV20=NaN; p50=NaN; sus50=NaN; fsl50=NaN; CV50=NaN;    
end

end