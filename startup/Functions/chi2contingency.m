function [chi2,p]=chi2contingency(dist1,dist2)




    x1=[repmat('a',sum(dist1),1);repmat('b',sum(dist2),1)];

    a=[];
    for i=1:length(dist1)
        a=[a;repmat(i,dist1(i),1)];
    end

    b=[];
    for i=1:length(dist2)
        b=[b;repmat(i,dist2(i),1)];
    end

    x2=[a;b];

    
    [tbl,chi2,p]=crosstab(x1,x2);
    
end


