clear
clc
close all

old_file_name = fullfile(pwd,'derp.m');

old_file_name
new_file_name = replace(old_file_name,{'derp','.m'},{'derpderp','.mat'})

save(new_file_name,'old_file_name')








