function [result bb F varargout]=unitTypingAuto(sst,varargin)
%
%
%
%% process varargin

% F=[];
graphic=false;
animate=false;
if ~isempty(varargin)
input_var=varargin;
name = input_var(1:2:nargin-1);
value = double(cat(2,input_var{2:2:nargin-1}));
for i=1:length(name)
    eval([name{i} '=' num2str(value(i)) ';']);
end
end
graphic=logical(graphic);
animate=logical(animate);

if animate
   graphic=true; 
end


%% main program
tic;
trsel=find_rf_trial(sst);
[x,y,data]=collect_data(sst,trsel);

rf_data = struct;
rf_data.x = x;
rf_data.y = y;
rf_data.data = data;

varargout{1} = rf_data;

%
bb = traceRF(x,y,data);
if ~isnan(bb)
    
    timetic=toc;
    fprintf('RF parsed in %.2f s. ',timetic);
    
    % plot PSTH
    m=min(bb(:,2));
    bfm=median(bb(bb(:,2)==m,1));
    [~,ix]=min(abs(x-bfm));
    bf=x(ix);
    thr=m;
    
    recruity=thr+15:5:thr+50;
    recruity(recruity>90)=[];
    [s,is]=sort(abs(x-bf));
    recruitx=x(is);

    if graphic
        co=get(0,'defaultaxescolororder');
        co=repmat(co,100,1);
        figure(gcf);clf;set(gcf,'position',[195.4000 337 560 420])
        a1=gca; a1.Color='none';
        a2=axes('position',[0.15 0.6 0.3 0.3]);
        
        set(a2,'xtick',[],'ytick',[],'xscale','log');hold on;axis off
        h=pcolor(x,y,data);colormap(gray);
        set(h,'edgecolor','none','facealpha',1);
        plot(bb(:,1),bb(:,2),'k:','linewidth',2,'color','w');
        plot(thr,recruitx(1),'ko');
%         text(recruitx(1),thr-5,[num2str(round(recruitx(1)./1000)) ' kHz'],'fontsize',8,'horizontalalignment','center');
        
        a3=axes('position',[0.15 0.25 0.3 0.3]);
        if animate
            set(gcf,'position',[195.4000 337 560 420],'color','w')
            F(length(recruity)*7)=struct('cdata',[],'colormap',[]);
        end
    end
    
    count=0;
    tbl_classify=table;
    binsize=0.001;
    maxfr=ones(7*length(recruity),1);
    for i=1:7
        for j=1:length(recruity)
            tr=sst.TrialSelect('lev1',recruity(1:j),'frq1',recruitx(1:i));
            tr=tr(ismember(tr,trsel));
            ts=sst.GetSpikes(tr,'SW');
            if length(ts)>50
            count=count+1;
            X=0:binsize:0.2;
            Y=histcounts(ts,X,'normalization','pdf');

            psth = {X(1:end-1),Y};
            recr = {recruity(1:j),recruitx(1:i)};
            
            if graphic
                axes(a1);hold on
                if exist('hfl')
                   delete(hfl); 
                end
                if exist('hpsth')
                    delete(hpsth)
                end
                hpsth=plot(X(1:end-1),Y,'color',co(count,:));
                if length(ts)<50
                    mayx=0;
                else
                    mayx=max(get(a1,'ylim'));
                end
                maxfr(count)=mayx;
                try ylim([0 max(maxfr)]); end
                
                axes(a2);
                [by,bx]=ndgrid(recruity(1:j),recruitx(1:i));
                bxy=[reshape(by,[],1),reshape(bx,[],1)];
                hold on
                if exist('hdot')
                    delete(hdot);
                end
                hdot=plot(bxy(:,2),bxy(:,1),'o','markersize',3,'markerfacecolor',co(count,:),'color',co(count,:));
                xlim([min(x) max(x)])
                ylim([min(y) max(y)])
                

            else
%                 disp_progress(count,7*length(recruity));
            end
            

            ts_cell=cell(length(tr),1);
            for j=1:length(tr)
                ts_cell{j}=sst.GetSpikes(tr(j),'SW');
            end
            [cv_winter cv_young bin fsl fisi] = get_CV(ts_cell,binsize);
            [buslope,buCV,fittedline]=psth_slope(X,Y,fsl,fisi,binsize);
            
            if graphic
                if ~isnan(buslope)
                axes(a1);
                    hfl=plot(fittedline(:,1),fittedline(:,2),'k:','linewidth',2,'color',co(count,:));
                end
                axes(a3);
                cla
                cv=cv_winter(bin<0.15);
                plot(bin(bin<0.15),cv,'color',co(count,:));hold on
                plot(bin,cv_young,':','color',co(count,:));
                plot([fsl fsl],get(gca,'ylim'),'k:')
                ylim([0 1]);xlim([0.1 0.15]);
                set(a3,'xtick',[],'ytick',[],'box','off');
                plot(fsl+[0.015 0.020],[0.3 0.3],'k-','linewidth',1)

                drawnow;
                pause(0.2)
                if animate
                    F(count)=getframe(gcf);
                end
            end
            
            cv = {bin cv_winter cv_young};
            tbl_classify(count,:)=table(recr,psth,cv,fsl,fisi,buslope,buCV); 
            end
        end
    end
    %
    if ~isempty(tbl_classify)
        for i=1:height(tbl_classify)
            bin_psth=tbl_classify.psth{i,1};
            bin_cv=tbl_classify.cv{i,1};
            psth=tbl_classify.psth{i,2};
            fsl=tbl_classify.fsl(i);
            cv_w=tbl_classify.cv{i,2};
            cv_y=tbl_classify.cv{i,3};
            
            
            ix=find(bin_psth>=floor(fsl*1000)/1000,1);
            if ~isempty(ix)
                r_onset(i)=psth(ix);
                ix=bin_psth>=floor(fsl*1000)/1000+0.015&bin_psth<=floor(fsl*1000)/1000+0.02;
                r_sus(i)=mean(psth(ix));
                ix=bin_psth>=floor(fsl*1000)/1000+0.035&bin_psth<=floor(fsl*1000)/1000+0.045;
                r_build(i)=mean(psth(ix));
            else
                r_onset(i)=NaN;
                r_sus(i)=NaN;
                r_build(i)=NaN;
            end
            
            tcv(i)=nanmean(cv_w(bin_cv>=fsl&bin_cv<fsl+0.002));
            scv(i)=nanmean(cv_w(bin_cv>=fsl+0.015&bin_cv<fsl+0.02));
        end
        
        
        p_cht=sum(tcv<=0.3)./length(tcv);
        p_chs=sum(scv<=0.3)./length(scv);
        rr=[r_onset' r_sus' r_build'];
%         p_bu=sum(rr(:,3)>rr(:,2))./size(rr,1);
        p_bu=sum(tbl_classify.buslope>0)./sum(~isnan(tbl_classify.buslope));
        p_pause=sum(rr(:,1)>rr(:,2)&rr(:,1)>rr(:,3))./size(rr,1);
        p_onset=sum(rr(:,1)>5*rr(:,2)&rr(:,1)>5*rr(:,3))./size(rr,1);
        fsl=[nanmean(tbl_classify.fsl)-0.1 nanstd(tbl_classify.fsl)]*1000;
        fisi=[nanmean(tbl_classify.fisi) nanstd(tbl_classify.fisi)]*1000;
        max_bu=nanmax(tbl_classify.buslope);
        fit_bu=nanmin(tbl_classify.buCV);
        result = table(bf,thr,p_cht,p_chs,p_bu,p_pause,p_onset,max_bu,fit_bu,fsl,fisi);

    else
       result=table;
    end
else
       result=table; 
end

fprintf('\n')

if ~exist('F')
   F=NaN; 
end

end


function [buslope,buCV,fittedline]=psth_slope(X,Y,fsl,fisi,binsize)
%%
Xc=X(1:end-1);
ix=Xc>fsl+fisi&Xc<fsl+0.05;
if sum(ix)>3
    M=[ones(size(Xc(ix)))' Xc(ix)']\Y(ix)';
    
%     debug only:
%     clf;figure(gcf);hold on
%     plot(Xc(ix),Y(ix),'o');
%     plot(Xc(ix),Xc(ix)*M(2)+M(1))

    buslope=M(2);
    fittedline=[Xc(ix)' (Xc(ix)*M(2)+M(1))'];
    ssq=(Y(ix)'-fittedline(:,2)).^2;
    buCV=std(ssq)./mean(ssq);
else
    buslope=NaN;
    buCV=NaN;
    fittedline=NaN;
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

function [x,y,data]=collect_data(sst,trsel)
%%
y=sst.SortedEpocs('lev1',trsel);
x=sst.SortedEpocs('frq1',trsel);

x(x==200)=[];
data=[];
for i = 1:length(x)
    for j = 1:length(y)
        idx=sst.TrialSelect('frq1',x(i),'lev1',y(j));
        idx=idx(ismember(idx,trsel));
        data(j,i)=SpikeRate(sst,[0 0.05],idx,'type','S1','norm','rate')-SpikeRate(sst,[0 0.05],idx,'type','SW','norm','rate');
    end
end

end




%%
function [traced_line,facto] = traceRF(x,y,data)
%
%


count=1;
[iall,jall]=find(ones(size(data))==1);
[~,vall]=boundary(iall,jall,1);

special_case=false;

if sum(data(1,:)==0)./length(data(1,:))>0.8
    special_case=true;

    
    u=unique(data);
    bin=find(u>0)';
    v=NaN(size(bin));
    thr=v;
    for facto=bin
        ul=u(facto);
        z=double(data>ul);
        [i,j]=find(z==1);
        [k,v(count)]=boundary(i,j,1);
        if k>0
            thr(count)=min(y(i(k)));
        end
        
        %                                       debugging only
%                                                 clf;
%                                                 pcolor(data);hold on;plot(j(k),i(k),'w-')
%                                                 title(facto)
%                                                 drawnow;
%                                                 pause(1);
            count=count+1;

    end

    
    
    
    
else

%boundary criteria, aka how many SD of spontaneous rate define active area
bin=0:0.1:20;
v=NaN(size(bin));
thr=v;

for facto=bin
    ul=nanmean(data(1,:))+facto*nanstd(data(1,:));
    z=double(data>ul);
    [i,j]=find(z==1);
    [k,v(count)]=boundary(i,j,1);
    if k>0
        thr(count)=min(y(i(k)));
    end

% %                                       debugging only
%                                     clf;
%                                     pcolor(data);hold on;plot(j(k),i(k),'w-')
%                                     title(facto)
%                                     drawnow;
%                                     pause(0.01);
    count=count+1;
end
v=v./vall;
end

%%
% %                                       debugging only
% clf;hold on;figure(gcf)
% nv = abs((v)-normalize01(thr));
% yyaxis left
% plot(bin,(v))
% plot(bin,nv);
% yyaxis right
% % % plot(bin,normalize01(thr))
% plot(bin,thr);
% % 
% [~,ix]=min(nv);
% vmat=sortrows(unique([nv(ix:end)',thr(ix:end)'],'rows'),1);
% vmat=vmat(vmat(:,1)>min(vmat(:,1))&vmat(:,2)>min(vmat(:,2)),:);
% ix=find(nv==vmat(1,1)&thr==vmat(1,2),1,'last');
% facto_set=bin(ix)




%%
skip=false;


%     I=bin(thr==mode(thr(~isnan(thr)&v<0.4)));
%     if ~isempty(I)
%         facto_set = I(1);
%     else
%         facto_set=bin(end);
%     end
    
% method2
nv = abs((v)-normalize_mod(thr));
[~,ix]=min(nv);
vmat=sortrows(unique([nv(ix:end)',thr(ix:end)'],'rows'),1);
vmat=vmat(vmat(:,1)>min(vmat(:,1))&vmat(:,2)>min(vmat(:,2)),:);
if ~isempty(vmat)
ix=find(nv==vmat(1,1)&thr==vmat(1,2),1,'last');
facto_set=bin(ix);
z=double(data>nanmean(data(1,:))+facto_set*nanstd(data(1,:)));
else
    skip=true;
end




if ~skip
% if special_case
%     u=unique(data);
%     iul=find(u>0);
%     ul=u(iul(1));
%     z=double(data>ul);
% end
[i,j]=find(z==1);
[k,v]=boundary(i,j,1);
else
    k=[];
end

if ~isempty(k)
bb=[x(j(k)),y(i(k))];
[m,im]=max(bb(:,1));
bb(1:im,2)=max(y);

ff=find(abs(zscore(bb(:,2)))>3|[abs(zscore(diff(bb(:,2))));0]>3);
% for i=1:length(ff)
%    [~,is]=sort(abs([1:size(bb,1)]-ff(i)));
%    bb(ff,2)=median(bb(is(2:3),2)); 
% end

% ff=abs(diff(bb(:,2)))>30;
bb(ff,:)=[];

traced_line = bb;
else
  traced_line=NaN;
  facto=NaN;
end

%% debug only
% clf;
% set(gca,'xtick',[],'ytick',[],'xscale','log');hold on;axis off
%         h=pcolor(x,y,data);colormap(gray);
%         set(h,'edgecolor','none','facealpha',1);
%         plot(traced_line(:,1),traced_line(:,2),'k:','linewidth',2,'color','w');


end


