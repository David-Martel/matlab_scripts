function burst = burst_ps(spiketrain,interval,showplot)
%
%
%
%

%% poisson surprise variable spikes

crit=10;
if showplot
    figure('position',[1 280 1280 200])
    hold on
end
burst=[];
ls=spiketrain;
if ~isempty(ls)
    r=length(ls)./interval; % expected spike rate
    
    
    index=zeros(length(ls)-2,1); % create a index to tag times where >10 surprise occurs
    Pline=[];
    for i=1:length(ls)-2
        P=-log2(poisspdf(3,r*(ls(i+2)-ls(i))));
        if P>10&r*(ls(i+2)-ls(i))>3
            P=NaN;
        end
        Pline(i)=P;
        
        if P>crit
            index(i)=1;
        end
    end
    
    % plots triplet results
    if showplot
        plot(ls(1:end-2),Pline);
        ph=round(max(Pline))+1;
        plot(ls,ones(length(ls),1)*ph,'+');
    end
    
    index=find(index==1);
    
    if ~isempty(index)
        for i=1:length(index) % for every tagged time, determine whether more spikes can be recruited to increase P
            ind=index(i);
            c=3;
            P=-log2(poisspdf(c,r*(ls(ind+c-1)-ls(ind))));
            if ind+3<=length(ls) % disregard the last triplet which would exceed total length of timestamps
                while P<-log2(poisspdf(c+1,r*(ls(ind+c)-ls(ind))))&c<length(ls)-ind
                    P=-log2(poisspdf(c+1,r*(ls(ind+c)-ls(ind))));
                    c=c+1;
                end
            end
            burst(i,:)=[P,c,ls(ind),ls(ind+c-1)];
            % save P,number of spikes,spike start,spike end for
        end
        
        % determine if identical burst with fewer spikes (different burst start) would result in higher P
        testarray=burst(:,4);
        val=unique(testarray);
        nfind=histc(testarray,val);
        nfind=val(nfind>1);
        
        if ~isempty(nfind)
            collect=[]; % save value with higher P out of identical bursts
            for i=1:length(nfind)
                comp=find(testarray==nfind(i));
                collect(i,:)=burst(comp(find(burst(comp,1)==max(burst(comp,1)))),:);
            end
            burst(ismember(testarray,nfind),:)=[]; % delete all duplicate bursts
            burst=sortrows([burst;collect],3); % put back selected bursts
            
        end
        
        % determine whether bursts overlap and delete based on two levels of
        % comparisons: 1. keep burst with higher spike count, 2. if burst count
        % equals, keep burst with higher P.
        list=[];
        for i=1:size(burst,1)-1
            if burst(i+1,3)<burst(i,4);
                if burst(i,2)==burst(i+1,2)
                    if burst(i,1)>burst(i+1,1)
                        list=[list i+1];
                    else
                        list=[list i];
                    end
                elseif burst(i,2)>burst(i+1,2)
                    list=[list i+1];
                elseif burst(i,2)<burst(i+1,2)
                    list=[list i];
                end
            end
        end
        burst(list,:)=[];
        
        if showplot
            for i=1:size(burst,1)
                plot([burst(i,3) burst(i,4)],[1 1]*(ph+1),'-','linewidth',4)
            end
            title(sprintf('bursts: %d',i))
            xl=get(gca,'xlim');
        end
    else
        burst=NaN;
    end
    
    if showplot
        line(xl,[crit crit],'linestyle',':')
        drawnow
    end
else
    burst=NaN;
end

if ~isnan(burst)
   burst = array2table(burst,'variablenames',{'ps','n','b_start','b_end'}); 
end








end