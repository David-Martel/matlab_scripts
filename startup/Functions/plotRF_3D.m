function h = plotRF_3D(x,y,data)

Z=reshape(data,numel(data),1);
Y=repmat(y,numel(data)./length(y),1);
X=reshape(transpose(repmat(x,1,numel(data)./length(x))),numel(data),1);
RF = fit([X Y],Z,'linearinterp');
plot(RF)
view([50 50])

end