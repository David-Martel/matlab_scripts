function populate_functions(remote_server,remote_func_folder,...
    startup_folder)
%% Get and update useful functions list
%
% shore_server = '\\corefs2.med.umich.edu\Shared3\Shore-Lab-Science';
% func_folder = 'khri-ses-lab\DavidM\Analysis\Functions';
%
% remote_server = 'G:\Shared drives\[Shore] Lab Server\';
% remote_func_folder = 'Functions';
% figure this out instead: https://docs.github.com/en/github/managing-files-in-a-repository/adding-a-file-to-a-repository-using-the-command-line

remote_func_dir = fullfile(remote_server,remote_func_folder);

if isempty(startup_folder)
    startup_folder = pwd;
end

local_func_dir = fullfile(startup_folder,'Functions');

if ~exist(local_func_dir,'dir')
    mkdir(local_func_dir);
else
    addpath(genpath(local_func_dir));
end

md5_func = which('GetMD5.mexw64');
if ~isempty(md5_func)
    md5_path = fileparts(md5_func);
    addpath(md5_path);
end

if exist(remote_func_dir,'dir')
    
    smart_copyfile(local_func_dir,remote_func_dir);
    %% copy any local functions into shore server function list
    %local_list = dir(fullfile(local_func_dir,'\*.m'));
    smart_copyfile(remote_func_dir,local_func_dir);
    
    fprintf(1,'Updated functions folder files\n')
else
    fprintf(1,'No access to remote server\n')
end

addpath(genpath(local_func_dir));


function smart_copyfile(source_dir,dest_dir)

source_list = dir(source_dir);

for idx_func = 1:length(source_list)
    
    try
        local_func_name = source_list(idx_func).name;
        local_func = fullfile(source_dir,local_func_name);
        
        if isfolder(local_func) || contains(local_func,'.mex')
            
        else
            
            server_func = replace(local_func,source_dir,dest_dir);
            
            if ~exist(server_func,'file')
                success = copyfile(local_func,server_func,'f');
                
                if ~success
                    fprintf(1,'Error copying: %s\n',local_func)
                end
            else
                
                if ~strcmp(GetMD5(local_func,'File','hex')...
                        ,GetMD5(server_func,'File','hex'))
                    
                    local_info_time = source_list(idx_func).datenum;
                    server_info = dir(server_func);
                    
                    if local_info_time > server_info.datenum
                        success = movefile(local_func,server_func,'f');
                    else
                        success = movefile(server_func,local_func,'f');
                    end
                    
                    if ~success
                        fprintf(1,'Error copying: %s\n',local_func)
                    end
                end
                
            end
        end
    catch MException
        fprintf(1,'error copying file: %s\n',local_func_name);
    end
end


%% copy server functions to local storage
%     func_list = dir(remote_func_dir); %dir(fullfile(remote_func_dir,'\*.m'));
%     for idx_func = 1:length(func_list)
%
%         server_func_file = func_list(idx_func).name;
%         if isfolder(server_func_file)
%
%         else
%
%             server_func = fullfile(remote_func_dir,server_func_file);
%             local_func = replace(server_func,remote_func_dir,local_func_dir);
%
%             if ~exist(local_func,'file')
%
%                 success = copyfile(server_func,local_func,'f');
%
%                 if ~success
%                     fprintf(1,'Error copying: %s\n',server_func)
%                 end
%
%             else
%
%                 hash_value_local = GetMD5(local_func,'File','hex');
%                 hash_value_server = GetMD5(server_func,'File','hex');
%
%                 if ~strcmp(hash_value_local,hash_value_server)
%
%                     local_info = dir(local_func);
%                     server_file_date = func_list(idx_func).datenum;
%
%                     if local_info.datenum > server_file_date
%                         success = copyfile(local_func,server_func,'f');
%                     else
%                         success = copyfile(server_func,local_func,'f');
%                     end
%
%                     if ~success
%                         fprintf(1,'Error copying: %s\n',local_func)
%                     end
%
%                 end
%
%
%             end
%         end
%     end
%


