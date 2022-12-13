function [old_dirs,new_dirs] = rename_path(dir_list,source_str,dest_str)

%
old_dirs = dir_list(contains(dir_list,source_str,'IgnoreCase',true));
new_dirs = cell(size(old_dirs));
for dir_iter = 1:length(old_dirs)
    
    dir_item = old_dirs{dir_iter};
    dir_parts = strsplit(dir_item,filesep);
    
    dir_loc = contains(dir_parts,source_str,'IgnoreCase',true);
    dir_parts{dir_loc} = {dest_str};
    
    
    new_dirs(dir_iter) = fullfile(dir_parts{:});
    
end










