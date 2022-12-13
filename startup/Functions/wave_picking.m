function data_nf = wave_picking(data,varargin)
% This function extracts ABR waveform data (output of the ARF2mat function)
% and perform semi-automatic peak and volley picking.
% input: data (struct)
% output: wave_result (table)


%%
% ff = 'U:\2Data\ABRs\Calvin\export_test\SC7.txt';
% data = ARF2mat(ff,'verbose',1)

%check if already exist
if isempty(varargin)
proceed = ~isfield(data,'wave_result')||isempty(data.wave_result);
elseif varargin{1}|varargin{1}==1
    proceed = true;
end
if proceed

% clc
groups = data.groups(data.groups.record_numbers>3,:);
records = data.records; %(data.records.n_averages>10,:);

gi=1;
while gi<=height(groups)
    clc
    idx = records.index == groups.index(gi);
    wf = records.waveform(idx,:);
    titlestr=sprintf('Redraw (L) or Confirm (R). (%d/%d)',gi,height(groups));
    disp(titlestr)
    gi_index = groups.index(gi);
    [p1_data,b] = wave_pickGUI(data,records,gi_index,idx,wf);
    if gi==1&b==3
        wave_result = p1_data;
        gi=gi+1;
    elseif b==3
        wave_result = [wave_result;p1_data];
        gi=gi+1;
    end
end
data_nf=data;
data_nf.wave_result = wave_result;


close all;
else
data_nf = data;    
end

end



function [p1_data,b] = wave_pickGUI(data,records,gi,idx,wf)
%%
clf
x=linspace(0,data.duration,data.samples);
y=records.level(idx);
freq=records.frequency(idx);
[y,yi]=sort(y,'descend');
imagesc(x,1:length(y),wf(yi,:));
set(gca,'ytick',1:length(y),'yticklabel',num2cell(y))
set(gcf,'defaulttextinterpreter','none')
title(sprintf('%s (%s), %s, %d Hz',data.groups.subject{gi},data.groups.side{gi},data.groups.time_point{gi},freq(1)))
button=1;
while button~=3
    if exist('h')
        delete(h)
    end
    %     h = impoly;
    h=imfreehand;
    ll = getPosition(h);
    %
    [~,~,button]=ginput(1);
    %     if size(ll,1)<9&size(ll,1)>1
    %         button=1;
    %         disp('Need minimum of 9 points');
    %     end
end

try
    
    hold on
    ll(end+1,:)=ll(1,:);
    %     line(ll(:,1),ll(:,2),'linewidth',2);
    llx = interp(ll(:,1),100);
    lly = interp(ll(:,2),100);
    ll = [llx,lly];
    co=get(groot,'defaultaxescolororder');
    co=repmat(co,3,1);
    %
    clf
    set_limit = [ceil(min(ll(:,2))):floor(max(ll(:,2)))]';
    [~,im]=max(ll(:,2));
    if y(1)==0&set_limit(1)==0
        set_limit(1)=[];
    end
    
    peak_data=NaN(length(set_limit),4);
    for i=1:length(set_limit)
        integer=set_limit(i);
        xbound_loc = [find(abs(ll(1:im,2)-integer)==min(abs(ll(1:im,2)-integer)),1),...
            find(abs(ll(im+1:end,2)-integer)==min(abs(ll(im+1:end,2)-integer)),1)+im];
        xbound = ll(xbound_loc,1);
        xbound_idx = x>min(xbound)&x<max(xbound);
        
        subplot(1,2,1)
        plot(x(xbound_idx),wf(integer+1,xbound_idx));hold on
        
        [volley,ivolley] = min(wf(integer+1,xbound_idx));
        [peak,ipeak] = max(wf(integer+1,xbound_idx));
        fxidx = find(xbound_idx);
        peak_data(i,1)=x(fxidx(ivolley));
        peak_data(i,2)=x(fxidx(ipeak));
        peak_data(i,3)=volley;
        peak_data(i,4)=peak;
        
        plot(x(fxidx(ivolley)),volley,'v','color',co(i,:))
        plot(x(fxidx(ipeak)),peak,'^','color',co(i,:))
    end
    
    p1_data = array2table([ones(length(set_limit),1)*gi y(set_limit) peak_data],...
        'VariableNames',{'index','level','t_volley','t_peak','amp_volley','amp_peak'});
    
    subplot(1,2,2)
    hold on
    plot(p1_data.level,p1_data.t_volley,'v-')
    [h1,h2,h3]=plotyy(p1_data.level,p1_data.t_peak,...
        p1_data.level,p1_data.amp_peak-p1_data.amp_volley);
    h2.Color=co(3,:); h2.Marker='^';
    h3.Color=co(2,:); h3.Marker='o';
    plot(p1_data.level,p1_data.t_peak,'^-','color',co(3,:))
    title(sprintf('%s (%s), %s, %d Hz',data.groups.subject{gi},data.groups.side{gi},data.groups.time_point{gi},freq(1)))

catch
    
    p1_data = table([],[],[],[],[],[],'VariableNames',{'index','level','t_volley','t_peak','amp_volley','amp_peak'});
    
end

[~,~,b]=ginput(1);

end
