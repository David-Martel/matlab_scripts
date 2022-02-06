
if ~isdeployed()
    %% Get and update useful functions list
    startup_dir = getenv('MATLABSTART');
    remote_server = 'G:\Shared drives\damartel\MATLAB'; %'G:\My Drive\MATLAB'; %
    remote_func_folder = 'Functions';
    
    if exist(fullfile(remote_server,remote_func_folder),'dir')
        populate_functions(remote_server,remote_func_folder,startup_dir);
    else
        fprintf(1,'cannot find remote directory\n')
    end
end

close all
disp('Bye!')






