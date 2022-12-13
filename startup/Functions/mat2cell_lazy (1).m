function c = mat2cell_lazy(m,dim)

matsize = size(m);
cellsize = ones([1 length(matsize)]);

cellsize(dim) = matsize(dim);
% if dim==2
%     cellsize(1) = matsize(2);
% else
%     cellsize(2) = matsize(1);
% end

reorder_size = 1:ndims(matsize); %cat(2,dim,matsize([
reorder_size = cat(2,dim,reorder_size(reorder_size~=dim));

c = cell(cellsize);
m = permute(m,reorder_size);

for dim_iter = 1:matsize(dim)
    
    c{dim_iter} = ipermute(m(dim_iter,:),reorder_size);
    
end

