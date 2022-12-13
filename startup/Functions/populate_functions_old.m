function populate_functions(remote_server,remote_func_folder)
%% Get and update useful functions list

% shore_server = '\\corefs2.med.umich.edu\Shared3\Shore-Lab-Science';
% func_folder = 'khri-ses-lab\DavidM\Analysis\Functions';
%
% remote_server = 'G:\Shared drives\[Shore] Lab Server\';
% remote_func_folder = 'Functions';
%figure this out instead: https://docs.github.com/en/github/managing-files-in-a-repository/adding-a-file-to-a-repository-using-the-command-line

remote_func_dir = fullfile(remote_server,remote_func_folder);

startup_folder = pwd;

local_func_dir = fullfile(startup_folder,'Functions');

if ~exist(local_func_dir,'dir')
    mkdir(local_func_dir);
end


if exist(remote_func_dir,'dir')
    
    %copy server functions to local storage
    func_list = dir(fullfile(remote_func_dir,'\*.m'));
    for idx_func = 1:length(func_list)
        server_func = fullfile(remote_func_dir,func_list(idx_func).name);
        local_func = replace(server_func,remote_func_dir,local_func_dir);
        
        if ~exist(local_func,'file')
            
            success = copyfile(server_func,local_func,'f');
            
            if ~success
                fprintf('Error copying: %s\n',server_func)
            end
            
        end
    end
    
    %copy any local functions into shore server function list
    local_list = dir(fullfile(local_func_dir,'\*.m'));
    for idx_func = 1:length(local_list)
        local_func = fullfile(local_func_dir,local_list(idx_func).name);
        server_func = replace(local_func,local_func_dir,remote_func_dir);
        
        if ~exist(server_func,'file')
            success = copyfile(local_func,server_func,'f');
            
            if ~success
                fprintf('Error copying: %s\n',local_func)
            end
            
        end
    end
    
    disp('Updated functions folder files')
else
    disp('No access to remote server')
end

addpath(genpath(local_func_dir));

