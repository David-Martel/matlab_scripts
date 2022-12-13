clear
clc
close all

source_dir = 'F:\GDriveMirror';
dest_dir = 'V:\GDriveMirror';


source_files = getAllFiles(source_dir);

dest_files = replace(source_files,source_dir,dest_dir);


num_source_files = length(source_files);

status_list = nan(num_source_files,1);

for file_iter = 1:num_source_files
    
    source_file = source_files{file_iter};
    
    dest_file = dest_files{file_iter};
    
    if ~exist(dest_file,'file')
        
        [dest_path] = fileparts(dest_file);
        if ~exist(dest_path,'dir')
            mkdir(dest_path);
        end
        
        [success,msg] = copyfile(source_file,dest_file,'f');
        status_list(file_iter) = success;
    else
        status_list(file_iter) = 0;
    end
    
    
    
end














