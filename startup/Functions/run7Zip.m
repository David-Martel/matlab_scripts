function response = run7Zip(archive_name,archive_files)

exe_str = 'C:\Program Files\7-Zip\7z.exe';
response = '';

if ~exist(exe_str,'file')
    response = 'exe not found';
    return
end

if exist(archive_name,'file')
    disp('over writing old archive')
    delete(archive_name);
end

command_str = 'a';

if ~isa(archive_files,'cell')
    archive_files = {archive_files};
end

archive_files_string = strcat('"',archive_files,'" | ');
archive_files_string((end-2):end) = [];

seven_zip_command = strjoin(exe_str,' ',command_str,' ')


















