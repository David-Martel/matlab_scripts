clear
clc
close all

source_path = pwd;
source_dir = 'VCN_Dec-14-2018';
base_files = fullfile(source_path,getAllFiles(source_dir));

dest_path = source_path;
dest_dir = fullfile(dest_path,'VCN_Dec-15-2018');


num_base_files = length(base_files);

for idx = 1:num_base_files
    
    base_file = base_files{idx};
    
    new_target_file = strrep(base_file,fullfile(source_path,source_dir),dest_dir);
    
    if exist(new_target_file,'file')
        
        %compute hashes of each file
        files_equivalent = compare_files(base_file,new_target_file);
        if isnan(files_equivalent)
            fprintf('error on %s\n',base_file);
            drawnow;
        elseif files_equivalent
            delete(base_file);
        else
            
            file_props_base = dir(base_file);
            date_base = file_props_base.datenum;
            
            file_props_target = dir(new_target_file);
            date_target = file_props_target.datenum;
            
            if date_base <= date_target %target is newer than source
                delete(base_file);
            elseif date_base > date_target %source is newer than target
                success = movefile(base_file,new_target_file,'f');
            end
            
        end  
    else
        [path_part,filename] = fileparts(new_target_file);        
        if ~exist(path_path,'dir')
            mkdir(path_path);
        end
        
        success = movefile(base_file,new_target_file,'f');
    end
    
    if mod(idx,100) == 0
        fprintf('finished %d/%d\n',idx,num_base_files);
        drawnow;
    end
    
    
end


folder_list = fullfile(source_path,source_dir);
folder_list = dir(folder_list);

folder_names = cell(length(folder_list),1);
for idx = 1:length(folder_list)
    name = fullfile(folder_list(idx).folder,folder_list(idx).name);
    
    rmdir name
    
end





















