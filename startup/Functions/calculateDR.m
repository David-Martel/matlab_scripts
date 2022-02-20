function [DR,ll,uu]=calculateDR(x,y)
    ysm=smooth(y);
    ysm(end)=ysm(end-1);
    rate_diff=diff(ysm);
    ft=fit(x,ysm,'smoothingspline');
    X=[0:0.1:100];
    dX=differentiate(ft,X);
    crit=max(dX)*0.2;
    anTable=[transpose([1:length(X)]),X',dX];
    cp1=find(anTable(:,3)==max(dX));
    cpPlus=find(anTable(:,1)>cp1-1&anTable(:,3)>crit);
    if ~isempty(find(diff(cpPlus)~=1))
        uu=anTable(min(cpPlus(find(diff(cpPlus)~=1))),2);
    else
        uu=anTable(max(cpPlus),2);
    end        
    cpMinus=find(anTable(:,1)<cp1+1&anTable(:,3)>crit);
    if ~isempty(find(diff(cpMinus)~=1))
        ll=anTable(max(cpMinus(find(diff(cpMinus)~=1)+1)),2);
    elseif isempty(cpMinus)|cpMinus(1)==1
        ll=0;
    else
        ll=anTable(min(cpMinus),2);
    end
    DR=uu-ll;
end

