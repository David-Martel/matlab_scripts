clear
clc
close all

move_dir = 'C:\TrialCode\TinData';
core_dir = 'G:\OneDrive\TinDevice\TinData';

sub_dir = 'S001';


move_sub = fullfile(move_dir,sub_dir);
core_sub = fullfile(core_dir,sub_dir);


[move_file_list,move_file_dates,move_file_sizes] = getAllFiles(move_sub);
[core_file_list,core_file_dates,core_file_sizes]  = getAllFiles(core_sub);

move_hash_vals = cellfun(@getFileHash,move_file_list,'uniformoutput',false);
core_hash_vals = cellfun(@getFileHash,core_file_list,'uniformoutput',false);

overlap_list = replace(move_file_list,move_sub,core_sub);

[in_core_idx,move_idx] = ismember(move_hash_vals,core_hash_vals);

files_delete_safe = move_file_list(in_core_idx); %contents are equivalent between directories


compare_files_move = move_file_list(~in_core_idx);

compare_move_dates = move_file_dates(~in_core_idx);
compare_core_dates = core_file_dates(~in_core_idx);

move_files_newer = gt(compare_move_dates,compare_core_dates);

compare_move_sizes = move_file_sizes(~in_core_idx);
compare_core_sizes = core_file_sizes(~in_core_idx);









