function [qx,q,lower,upper,bf,thr] = qx_db(x,y,rf_data,q,varargin)


%%
if isempty(varargin)
    [bf,thr,~,~,datacor]=autoCellType(x,y,rf_data);
elseif nargin==6
    [~,~,~,~,datacor]=autoCellType(x,y,rf_data);
    bf=varargin{1};
    thr=varargin{2};
elseif nargin~=6
    warning('BF and Thr invalid. Determine automatically');
    [bf,thr,~,~,datacor]=autoCellType(x,y,rf_data);
end

lower=NaN;
upper=NaN;
qx=NaN;

%%
if ~isnan(thr)
    while isnan(qx)&q<90
    y_sel = thr+q;
    if y_sel>max(y)
       y_sel=max(y); 
    end
    [~,imin]=min(abs(y-y_sel));
    
    r_at_q = datacor(imin,:);
    
    recruit=3;
    resp=zeros(length(r_at_q)-recruit-1,1);
    for i=1:length(r_at_q)-recruit-1
        resp(i)=sum(r_at_q(i:i+recruit-1))==recruit;
    end
    
    border = [min(find(resp==1)) max(find(resp==1))+recruit-1];
    if ~isempty(border)
        lower = x(border(1));
        upper = x(border(2));
        qx = bf./(upper-lower);
        % clf
        % h=pcolor(x,y,datacor);
        % hold on
        % plot(bf,thr,'o','markersize',20,'color',[0.5 0.5 0.5])
        % set(gca,'xscale','log','xtick',downsample(x,4));
        % set(h,'edgecolor','none')
        % line(x(border),[y(imin) y(imin)],'color',[0.5 0.5 0.5],'linewidth',4)
        % waitforbuttonpress
    else
        lower=NaN;
        upper=NaN;
        qx=NaN;
        q=q+5;
    end
    end
end






end