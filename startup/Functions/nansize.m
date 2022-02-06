function [ sizewithoutnans ] = nansize( data, dimension)

%nansize This function allows size to ignore rows or columns where they are 
%full of NaNs

%[sizewithoutnans] = nansize( data, dimension)

sizewithoutnans = sum(~isnan(sum((data'),dimension)));

end