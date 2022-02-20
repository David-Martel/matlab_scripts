clear
clc
close all

base_dir = pwd;

[api_url,api_ip] = validate_redcap_url;

if isempty(api_url)
    return
end

api_token = get_machine_token;

serialize_data = true;

%% data for lookup payload
%this is where the documentation is relevant
%https://redcapproduction.umms.med.umich.edu/api/help/
data_lookup = 'record'; %'record';%,'event';%'exportFieldNames'; %

%Note: calling "record" will take a lot of time to download and process

core_type = data_lookup;

if strcmp(core_type,'record')
    data_lookup = [data_lookup '&type=flat'];
end
data_str = ['"'...
    'token=$API_TOKEN' '&'...
    'format=json&returnFormat=json' '&'...
    'content=$CONTENT'...
    '" $API_URL'];

replace_strs = {'$API_TOKEN','$CONTENT','$API_URL'};
replace_vals = {api_token,data_lookup,api_url};

data_str = replace(data_str,replace_strs,replace_vals);

%% command for curl to get data
command_str = ['curl --header "Content-Type: application/x-www-form-urlencoded" '...
    '--header "Accept: application/json" '...
    '--ssl-reqd '...
    '--request POST '...
    '--silent --ipv4 '...
    '--data $DATA'];

replace_strs = {'$DATA'};
replace_vals = {data_str};

command_str = replace(command_str,replace_strs,replace_vals);
MException = [];

try
    [redcap_success,response] = system(command_str);
    
    
catch MException
    disp('Issue querying database');
    timestamp = datestr(now,'mmm-dd-yyyy_HH-MM-SS');
    
    save_data = fullfile(base_dir,['redcap-error_' timestamp '.mat']);
    save(save_data,'MException','command_str');
    
end

if isempty(MException) && ~redcap_success
    
    data_struct = jsondecode(response);
    
    timestamp = datestr(now,'mmm-dd-yyyy_HH-MM-SS');
    save_data = fullfile(base_dir,['redcap-database_type-' core_type '_' timestamp '.mat']);
    
    if serialize_data
        data_struct_serial = hlp_serialize(data_struct);
        save_data = replace(save_data,'redcap-database_','redcap-database-SERIAL_');
    else
        data_table = struct2table(data_struct);
        
        data_table = remove_empty_vars(data_table);
    end
    
    
    %% file management of old databases
    old_db_dir = fullfile(base_dir,'RedCapData');
    if ~exist(old_db_dir,'dir')
        mkdir(old_db_dir);
    end
    
    file_list = getAllFiles(base_dir);
    exist_db = contains(file_list,'redcap-database') & contains(file_list,'.mat') & contains(file_list,core_type) & ~contains(file_list,'RedCapData');
    if any(exist_db)
        exist_db_files = file_list(exist_db);
        exist_db_files_new = replace(exist_db_files,base_dir,old_db_dir);
        
        for file_iter = 1:length(exist_db_files)
            success = movefile(exist_db_files{file_iter},exist_db_files_new{file_iter},'f');
        end
    end
    if contains(save_data,'SERIAL')
        save_vars = {'data_struct_serial','response','command_str'};
    else
        save_vars = {'data_struct','data_table','response','command_str'};
    end
    
    save(save_data,save_vars{:});
end
