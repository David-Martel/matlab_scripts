function varargout = startup_local(startup_info)

status = false;

%% Get and update useful functions list
startup_env = getenv('MATLABSTART');
startup_dir = pwd;
local_func_dir = fullfile(startup_dir,'Functions');
if ~contains(path,local_func_dir)
    addpath(genpath(local_func_dir));
end

if isempty(startup_env) || ~strcmp(startup_dir,startup_env)
    setenv('MATLABSTART',startup_dir);
end



if isfield(startup_info,'remote_server') && exist(fullfile(startup_info.remote_server,startup_info.remote_func_folder),'dir')
    populate_functions(startup_info.remote_server,startup_info.remote_func_folder,startup_dir);
else
    fprintf(1,'cannot find remote directory\n')
end




%% Configure email server
try
%     [~,hostname] = system('hostname');
%     hostname(end) = [];    
%     username = getenv('username');
    [hostname,username] = whoami;

    if contains(hostname,'dtm') && contains(username,{'david','damartel'})
        email_str = 'damartel';
    else
        email_str = 'shorelab';
    end
    
    user_email = configure_umich_email(email_str);
    fprintf(1,'user email: %s\n',user_email);
    
catch
    fprintf(1,'error configuring email\n')
    user_email = '';
end
startup_info.user_email = user_email;

%% hardware graphics
gpu_info = opengl('data');
if contains(gpu_info.Vendor,'nvidia','ignorecase',true)
    feature('GpuAllocPoolSizeKb',intmax('int32'))
end
opengl('hardware')

%% derp
fprintf(1,'Hello %s!\n',username)

varargout{1} = startup_info;


