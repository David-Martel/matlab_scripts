function boundary_scalar = make_bound(bound_size,bound_offset)


[xx,yy] = meshgrid(1:bound_size,1:bound_size);

% bound_offset = 32;

xxs = sqrt(2).*bound_offset.*((xx-bound_offset))./bound_size;
yys = sqrt(2).*bound_offset.*((yy-bound_offset))./bound_size;

boundary_scalar = normcdf(xxs).*normcdf(yys);
boundary_scalar = boundary_scalar.*rot90(boundary_scalar,2);

