function [H ES] = STDP_index(X)

% X: n by 2 matrix, first column is interval (x), second column is relative
% change (y) for a STDP timing rule.
% e.g. X=[-20 -10 -5 5 10 20;(stdp_rep(35,:)-1)]'

if size(X,2)~=2
   error('Invalid size.') 
end

X(isnan(X(:,1))|X(:,1)==0,:)=[];


X(isinf(X(:,2))|isnan(X(:,2))|X(:,2)>2,:)=[];
   
    pos=sortrows(X(X(:,1)>0,:));
    neg=sortrows(X(X(:,1)<0,:));
    
    if size(pos,1)>1&size(neg,1)>1
        H=trapz(pos(:,1),pos(:,2))-trapz(neg(:,1),neg(:,2));
    else
        H=NaN;
    end
    
    X=sortrows(X);
    if size(X,1)>1
        ES=trapz(X(:,1),X(:,2));
    else
        ES=NaN;
    end  

end