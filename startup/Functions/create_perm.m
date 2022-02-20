function [perm,L] = create_perm(N)
% 
%
%

%%
L = uint32(factorial(N)./factorial(N-2)./2);
perm=zeros(L,2);
count=0;
for t=1:N
    for u=t+1:N
        count=count+1;
        perm(count,1)=t;
        perm(count,2)=u;
    end
end



end