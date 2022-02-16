

%% Randomize things
rng('shuffle')

if ~isdeployed()



    [status,response] = system('whoami');
    if ~status
        hostparts = strsplit(response,{'\',newline},"CollapseDelimiters",true);
        hostname = hostparts{1};
        username = hostparts{2};
        startup_info = struct;
        startup_info.remote_server = 'G:\Shared drives\damartel\MATLAB'; %'G:\My Drive\MATLAB'; %
        startup_info.remote_func_folder = 'Functions';

        try
            status = startup_local(startup_info);
        catch MException
            fprintf(1,'error starting up\m');
        end

    else
        fprintf(1,'error getting username, starting without functions\n');
    end



end

