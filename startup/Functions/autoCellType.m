function [bf,thr,monotonicity,ctype,datacor]=autoCellType(x,y,rf_data)

% output: best frequency, threshold monotonicity: 1=monotonic,
% 0=non-monotonic, -1=highly inhibitory, -2=inhibitory below SpAc
% ctype: 1=Type I, 3=Type III, 13=Type I/III, 4=type IV-T
%
% ***note: type II (rare) are included by the characteristics of type
% IV-T, need BBN response to separate II from IV-T.
%
% CW, 20-oct-14


bf=[];
thr=[];
monotonicity=[];
ctype=[];

% fprintf('Calling SST.. ')

data=rf_data;

ul=nanmean(data(1,:))+2*nanstd(data(1,:));
ll=nanmean(data(1,:))-2*nanstd(data(1,:));

datacor=double(data>ul)-double(data<ll);


recruit = 6;
sig_response = ttest2(reshape(data(1:recruit,:),numel(data(1:recruit,:)),1),...
    reshape(data(end-recruit+1,:),numel(data(end-recruit+1,:)),1));
sig_response(isnan(sig_response))=logical(0);
if sig_response
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
    else
        bf=NaN;
        thr=NaN;
    end
    
    %         figure('position',[600 200 500 420])
    
    %     subplot(2,2,1)
    % 	pcolor(x,y,datacor);
    % 	set(gca,'xscale','log');
    %     if ~isempty(bf)&~isempty(thr)&~isnan(bf)&~isnan(thr)
    %     line([bf bf],get(gca,'ylim'),'linewidth',2,'color','k')
    %     line(get(gca,'xlim'),[thr thr],'linewidth',2,'color','k')
    %     end
    
    %     subplot(2,2,3)
    % 	contour(x,y,data,25,'fill','on');
    %     set(gca,'xscale','log');
    if ~isempty(bf)&~isempty(thr)&~isnan(bf)&~isnan(thr)
        %     line([bf bf],get(gca,'ylim'),'linewidth',2,'color','k')
        %     line(get(gca,'xlim'),[thr thr],'linewidth',2,'color','k')
        
        %     subplot(2,2,2)
        rlf=smooth(data(:,find(x==bf)));
        %     plot(y,rlf)
        %     line([thr thr],get(gca,'ylim'))
        rlfdiff=diff(rlf(find(y==thr)+1:end));
        if isempty(rlfdiff(rlfdiff<0))
            monotonicity=1;
            %             title('Monotonic')
        elseif abs(rlfdiff(find(rlfdiff<0)))<abs(mean(rlfdiff))
            monotonicity=1;
            %             title('Monotonic')
        else
            monotonicity=0;
            %             title('Non-Monotonic')
            if sum(abs(rlfdiff(rlfdiff<0)))>=sum(abs(rlfdiff(rlfdiff>0)))
                monotonicity=-1;
                %                 title('Inhibitory')
                if min(rlf(find(y==thr)+1:end))<0
                    monotonicity=-2;
                end
            end
        end
        
        % 	subplot(2,2,4)
        indthr=find(y==thr+20);
        if ~isempty(indthr)&indthr+4<length(y)
            %     plot(x,data(indthr,:),'b');hold on
            %     plot(x,data(1,:),'r')
            %     hold off
            %     set(gca,'xscale','log','xlim',[min(x) max(x)]);
            %     line([bf bf],get(gca,'ylim'),'color','k')
            % 	line(get(gca,'xlim'),[0 0],'color','k')
            
            if thr~=0
                a=min(min(data(indthr:indthr+4,:)));
                c=min(data(1,:));
            else
                a=mean(reshape(data(indthr:indthr+4,:),numel(data(indthr:indthr+4,:)),1));
                c=0;
            end
            
            % fprintf('Determining cell type.. ')
            
            data=rf_data;
            if length(find(data(1,:)==0))>=round(length(data(1,:))/2)&nanmean(data(1,:))<1
                %             title(sprintf('%s %.1f','Tyle I/III',nanmean(data(1,:))))
                ctype=13;
                if monotonicity==-1
                    %                 title('Tyle IV-T')
                    ctype=4;
                end
            elseif a<=c
                %             title('Tyle III')
                ctype=3;
            elseif monotonicity==1
                %             title('Type I')
                ctype=1;
            elseif monotonicity==-1&thr<60
                %             title('Type IV-T')
                ctype=4;
            else
                ctype=NaN;
                
            end
            
            
            
        else
            %         title('Threshold too high')
        end
        
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


end