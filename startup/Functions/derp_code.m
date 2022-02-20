data = superblocks{1};
clf
for ch=1:32
    subplot(8,4,ch)
[u,a,b]=unique(data.block);
for i=1:max(b)
    datat = data.waves(b==i&data.chan==ch,:);
    x=mean(datat);
    plot(x);hold on
    text(30,x(end),num2str(u(i)))
end
end


%%