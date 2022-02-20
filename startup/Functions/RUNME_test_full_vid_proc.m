clear
clc
close all

base_dir = 'C:\Users\fatim\Documents\MATLAB';

addpath(genpath(base_dir));

gpu_dev = gpuDevice(1);

%base data locaiton
%addpath(genpath(base_dir))

animal_group = 'Y';
animal_folder = [animal_group '1'];

main_data_dir = fullfile(base_dir,'Data');
animal_data_dir = fullfile(main_data_dir,animal_folder);


save_dir = fullfile(main_data_dir,'SaveData');
if ~exist(save_dir,'dir')
    mkdir(save_dir);
end
animal_save_dir = fullfile(save_dir,animal_folder);

temp_dir = fullfile(base_dir,'TempData');
if ~exist(temp_dir,'dir')
    mkdir(temp_dir);
    addpath(temp_dir);
end

color_dir = fullfile(base_dir,'ColorData');

addpath(genpath('C:\Users\fatim\Documents\MATLAB\Analysis'))

%% Get job run time file
data_store_file = fullfile(temp_dir,[animal_group '_data-store.mat']);
if exist(data_store_file,'file')
    load(data_store_file,'cur_idx','vid_files','save_files','color_data','num_vid');
else
    cur_idx = 1;
    
    data_files = getAllFiles(animal_data_dir);
    vid_files = data_files(contains(data_files,'.mp4'));    
    
    save_files = replace(vid_files,{animal_data_dir,'.mp4'},{animal_save_dir,'.mat'});
    
    num_vid = length(vid_files);
    
    %Get color model
    path_list = cellfun(@fileparts,save_files,'uniformoutput',false);
    unique_path = unique(path_list);
    
    color_data = cell(num_vid,2);
    
    for path_iter = 1:length(unique_path)
        unique_path_entry = unique_path{path_iter};
        
        if ~exist(unique_path_entry,'dir')
            mkdir(unique_path_entry);
            addpath(unique_path_entry);
        end
        
        path_parts = strsplit(unique_path_entry,filesep);
        animal_name = path_parts{8}; %lazy person
        
        [colors,cl_thresh] = get_animal_color_model(color_dir,animal_name);
        ani_idx = contains(save_files,animal_name);
        
        color_data(ani_idx,1) = {colors};
        color_data(ani_idx,2) = {cl_thresh};
    end
    
    mat_files = data_files(contains(data_files,'presentation_order.mat'));
    mat_files(~cellfun(@(x) exist(x,'file'),mat_files)) = [];
    
    save_mat_files = replace(mat_files,animal_data_dir,animal_save_dir);
    
    for file_iter = 1:length(save_mat_files)
        new_path = fileparts(save_mat_files{file_iter});
        if ~exist(new_path,'dir')
            mkdir(new_path);
        end
        
        copyfile(mat_files{file_iter},save_mat_files{file_iter},'f');
    end
    save(data_store_file,'cur_idx','vid_files','save_files','color_data','num_vid');
end


%%
% priority('bn');
derp = 'Bad_Vid';

%% loop over videos
for idx_vid = cur_idx:num_vid
    
    profile on
    test_vid = vid_files{idx_vid};
    save_vid = save_files{idx_vid};
    colors = color_data{idx_vid,1};
    cl_thresh = color_data{idx_vid,2};
    
    if exist(save_vid,'file') && ~contains(save_vid,{'BAD','ERROR'})
        
    else
        
        try
            ear_pts = compute_ear_data(test_vid,save_vid,colors,cl_thresh);
            
        catch MException
            disp(sprintf('Error on %d/%d\n',idx_vid,num_vid)); %#ok<*DSPS>
            
            save_vid = replace(save_vid,'.mat','ERROR.mat');
            
            save(save_vid,'MException');
        end
        
    end
    
    %% update display to show current location in processing chain
    if mod(idx_vid,50) == 0
        disp(sprintf('finished vid: %d/%d\n',idx_vid,num_vid));
        java_pause(0.1);
        
        reset(gpu_dev);
        drawnow;
        
        cur_idx = idx_vid;
        save(data_store_file,'cur_idx','vid_files','save_files','color_data','num_vid');
    end
    
    if idx_vid == 500
        derp = 5;
    end
    
    
end

% priority('n');
% profile off
% profile viewer
% 
% profsave(profile('info'),'profile_results_gpu_2')





