function [file_status,new_src_files,new_dest_files] = migrate_directory(source_dir,dest_dir,varargin)

VERBOSE = false;
if any(contains(varargin,'verbose','ignorecase',true))
    VERBOSE = true;
end


[srcList,srcDate] = getAllFiles(source_dir);

[destList,destDate] = getAllFiles(dest_dir);

targetList = replace(srcList,source_dir,dest_dir);

new_file_idx = ~ismember(targetList,destList);
new_dest_files = targetList(new_file_idx); %these files need to be copied regardless
new_src_files = srcList(new_file_idx);

%%
srcFiles_in_destFiles = targetList(~new_file_idx);
srcDate_in_destFiles = srcDate(~new_file_idx);

[~,destIdx_srcFiles] = ismember(srcFiles_in_destFiles,destList);
destFiles_srcFiles = destList(destIdx_srcFiles);
destDate_srcFiles = destDate(destIdx_srcFiles);

date_comp = [destDate_srcFiles srcDate_in_destFiles];
name_comp = [destFiles_srcFiles srcFiles_in_destFiles];

dest_older_idx = date_comp(:,1) < date_comp(:,2);

dest_older_files = destFiles_srcFiles(dest_older_idx,1);

src_newer_files = replace(dest_older_files,dest_dir,source_dir);


%% copy new src files into destination
new_src_files = cat(1,new_src_files,src_newer_files);
new_dest_files = cat(1,new_dest_files,dest_older_files);

new_paths = unique(fileparts(new_dest_files));
for dir_iter = 1:length(new_paths)
    if ~exist(new_paths{dir_iter},'dir')
        mkdir(new_paths{dir_iter});
    end
    
end

num_file = length(new_src_files);
file_status = zeros(num_file,1);

for file_iter = 1:num_file
    stat_var = copyfile(new_src_files{file_iter},new_dest_files{file_iter},'f');
    
    file_status(file_iter) = stat_var;
    
    if VERBOSE
        if ~stat_var
            fprintf(1,'error moving %s\n',new_src_files{file_iter});
        else
            %fprintf(1,'success: %d/%d\n',file_iter,num_file);
        end
    end
end
% name_compare_test = cellfun(@(x,y) strcmp(x,y),name_comp(:,1),name_comp(:,2));













