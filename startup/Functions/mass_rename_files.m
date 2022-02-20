
clear
clc
close all

files = getAllFiles(pwd);

animal_rename = {'N5','N6','N7','N8'};
animal_actual = strrep(animal_rename,'N','M');

for idx = 1:length(files)
    
    file_name = files{idx};
    
    for idx2 = 1:length(animal_rename)
        
        if contains(file_name,animal_rename{idx2})
            new_file_name = strrep(file_name,animal_rename{idx2},animal_actual{idx2});
            
            path_name = fileparts(new_file_name);
            if ~exist(path_name,'dir')
                mkdir(path_name);
            end
            
            movefile(file_name,new_file_name,'f');
        end
    end
    
    
    
end













