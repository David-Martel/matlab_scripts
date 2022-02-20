function result = gpu_medfilt3(data,filt_size)


thresh = prod(filt_size)/2;

% filt = true(filt_size,'gpuArray');
filt = true(filt_size);

% data_gpu = gpuArray(data);

% gpu_result = convn(data_gpu,filt,'same');
gpu_result = convn(data,filt,'same');

% result = gather(gpu_result >= thresh);
result = gpu_result >= thresh;
%result = gather(gpu_result>=thresh);
disp('Over')
















