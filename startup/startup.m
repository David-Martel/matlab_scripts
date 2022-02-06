

%% Randomize things
rng('shuffle')

if ~isdeployed()
    
    remote_server = 'G:\Shared drives\damartel\MATLAB'; %'G:\My Drive\MATLAB'; %
    remote_func_folder = 'Functions';
    try
        status = startup_local(remote_server,remote_func_folder);
    catch MException
        fprintf(1,'error starting up\m');
    end
    
end

