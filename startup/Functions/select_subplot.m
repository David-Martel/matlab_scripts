function index = select_subplot(L)

index=[];
dimension=numSubplots(L);
H=dimension(1);
W=dimension(2);

for m=1:L
    subplot(H,W,m)
    ax(m,:)=get(gca,'position');
end

b=1;
count=0;
tag=[];
while b==1
    [x,y,b]=ginput(1);
    cp=get(gca,'position');
    index=find(round(ax(:,1)*100)/100==round(cp(1)*100)/100&round(ax(:,2)*100)/100==round(cp(2)*100)/100)
    if ~isempty(index)
        count=count+1;
        tag(count)=index;
    end
end
close all;
index=unique(sort(tag));


end