clear
clc
close all

utilities_dir = 'V:\Media_Utilities';
addpath(genpath(utilities_dir));

media_dir = 'V:\David_Media\';
base_hash = GetMD5(media_dir);

case_setting = {'IgnoreCase',true};

save_data_file = fullfile(utilities_dir,['image-info-struct_' base_hash '.mat']);
[file_list,file_date,file_size] = getAllFiles(media_dir);


%% remove local directory, desktop files from copy
os_data = {'.ini','.ds_store','.crdownload','.gz(busy)','thumbs.db'};
remove_idx = contains(file_list,os_data,case_setting{:});

file_list(remove_idx) = [];
file_date(remove_idx) = [];
file_size(remove_idx) = [];

%% 
num_files = length(file_list);

image_struct = struct;
for file_iter = num_files:-1:1
    
    filename = file_list{file_iter};
    [file_path,file_name,file_ext] = fileparts(filename);
    
    
    image_struct(file_iter).FilePath = file_path;
    image_struct(file_iter).FileName = file_name;
    image_struct(file_iter).FileExt = file_ext;
    
    image_struct(file_iter).FullFileName = filename;
    image_struct(file_iter).CreateDate= file_date(file_iter);
    image_struct(file_iter).FileSize = file_size(file_iter);
    
    image_struct(file_iter).MD5 = '';    
    image_struct(file_iter).CamDate = nan;
    
end

for file_iter = 1:length(file_list)

    file_name = file_list{file_iter};
    file_hash = GetMD5(file_name,'File');

    try
        file_info = imfinfo(file_name);
        make_date_str = file_info(1).DigitalCamera.DateTimeOriginal;
        make_date = datenum(make_date_str,'yyyy:mm:dd HH:MM:SS');

    catch
        make_date_str = '';
        make_date = nan;
    end

    image_struct(file_iter).CamDate = make_date;
    image_struct(file_iter).MD5 = file_hash;

end

save(save_data_file,'image_struct');
disp('saved image data');

%% Look for duplicates
image_table = struct2table(image_struct);

sort_vars = {'MD5','FilePath','FileName','CreateDate','CamDate'};

var_list = image_table.Properties.VariableNames;
var_list(ismember(var_list,sort_vars)) = [];
var_list = [sort_vars var_list];
image_table = image_table(:,var_list);

image_table = sortrows(image_table,sort_vars);

%% identify hashes and remove duplicates
[unique_hash_list,unique_hash_idx_new,unique_hash_idx_orig] = unique(image_table.MD5);
original_hash_list = image_table.MD5;

image_table_unique = image_table(unique_hash_idx_new,:);

unique_files = image_table_unique{:,'FileName'};
original_files = image_table{:,'FileName'};
duplicate_files = original_files(~ismember(original_files,unique_files),1);

dup_struct = struct;
dup_counter = 1;
for dup_iter = 1:length(unique_files)

    unique_hash = unique_hash_list{dup_iter};

    hash_idx = find(strcmp(original_hash_list,unique_hash));
    if length(hash_idx) > 1
        for hash_iter = 1:length(hash_idx)
            hash_idx_item = hash_idx(hash_iter);

            dup_struct(dup_counter).hash_idx = hash_idx_item;
            dup_struct(dup_counter).FullFileName = image_table.FullFileName(hash_idx_item);

            dup_struct(dup_counter).CreateDate = image_table.CreateDate(hash_idx_item);
            dup_struct(dup_counter).CamDate = image_table.CamDate(hash_idx_item);
            dup_struct(dup_counter).HashVal = unique_hash;

            dup_struct(dup_counter).FilePath = image_table.FilePath(hash_idx_item);
            dup_struct(dup_counter).FileName = image_table.FileName(hash_idx_item);
            dup_struct(dup_counter).FileExt = image_table.FileExt(hash_idx_item);
            
            dup_counter = dup_counter + 1;
        end
    end
end

duplicate_list = struct2table(dup_struct);
duplicate_list = sortrows(duplicate_list,{'HashVal','FilePath','FileName','FileExt'});

temp_dup_list = duplicate_list(:,{'HashVal','FilePath','FileName','FileExt','CreateDate','FullFileName'});




% temp_dup_list.FileNameLength = cellfun(@length,temp_dup_list.FullFileName,'uniformoutput',true);
% 
% hash_list = unique(temp_dup_list.HashVal);
% file_list_copy = cell(height(temp_dup_list),1);
% for hash_iter = 1:length(hash_list)
%    
%     hash_idx = strcmp(temp_dup_list.HashVal,hash_list{hash_iter});
%     
%     filename_length = temp_dup_list{hash_idx,'FileNameLength'};
%     hash_idx_vals = find(hash_idx);
%     
%     [min_hash_val,min_hash_idx] = min(filename_length);
%     
%     
%     
%     
%     
% end
% 
% 
% rep_idx = contains(temp_dup_list.FileName,'(',case_setting{:}) ...
%     & contains(temp_dup_list.FileName,')',case_setting{:});
% 
% delete_list = duplicate_list{rep_idx,'FullFileName'};
% % for del_iter = 1:length(delete_list)
% %    delete(delete_list{del_iter});
% % end





















