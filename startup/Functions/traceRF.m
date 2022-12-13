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
nv = abs((v)-normalize01(thr));
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
