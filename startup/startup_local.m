function varargout = startup_local(remote_server,remote_func_folder)

status = false;

%% Get and update useful functions list
startup_env = getenv('MATLABSTART');
startup_dir = pwd;

if isempty(startup_env) || ~strcmp(startup_dir,startup_env)
    setenv('MATLABSTART',startup_dir);
end

if exist(fullfile(remote_server,remote_func_folder),'dir')
    populate_functions(remote_server,remote_func_folder,startup_dir);
else
    fprintf(1,'cannot find remote directory\n')
end

local_func_dir = fullfile(startup_dir,'Functions');
addpath(genpath(local_func_dir));


%% Configure email server
try
    
    [~,hostname] = system('hostname');
    hostname(end) = [];    
    username = getenv('username');

    if contains(hostname,'dtm-work') && contains(username,'david')
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

%% hardware graphics

gpu_info = opengl('data');
if contains(gpu_info.Vendor,'nvidia','ignorecase',true)
    feature('GpuAllocPoolSizeKb',intmax('int32'))
end
opengl('hardware')

%% derp
user_name = getenv('username');

fprintf(1,'Hello %s!\n',user_name)

status = true;

varargout{1} = status;
varargout{2} = user_email;

