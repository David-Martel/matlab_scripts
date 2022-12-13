


% Prepare the input vectors (1M elements each)
x = rand(1e6,1);
y = rand(1e6,1);
 
% Compute the convolution using the builtin conv()
tic, z1 = conv(x,y); toc

% Now compute the convolution using fft/ifft: 780x faster!
n = length(x) + length(y) - 1;  % we need to zero-pad
tic, z2 = ifft(fft(x,n) .* fft(y,n)); toc

% Compare the relative accuracy (the results are nearly identical)
disp(max(abs(z1-z2)./abs(z1)))














