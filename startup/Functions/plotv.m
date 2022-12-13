function h_all=plotv(loc,xdata,xspread,ybin)
%
%
%
% xspread=0.2;
% ybin=2;
nbin=round(length(xdata)/ybin);
[N,edges,id]=histcounts(xdata,nbin);

h_all=[];
for i=1:length(N)
   corrected=transpose([1:N(i)]-median([1:N(i)]));
   if N(i)==1
      corrected=0; 
   end
        h=plot(loc+ones(N(i),1).*corrected*xspread,xdata(id==i),'o');
        h_all=[h_all;h];
end




end