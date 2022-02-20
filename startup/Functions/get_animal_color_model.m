function [colors,cl_thresh] = get_animal_color_model(color_dir,animal_name)

% data store location
animal_models = sprintf('color_model_%s*.mat',animal_name);

color_model_file = fullfile(color_dir,animal_models);
file_list = dir(color_model_file);

if isempty(file_list)
    
    [colors,cl_thresh] = get_base_color_model(color_dir);
else
    
    model = load(fullfile(color_dir,file_list(1).name),'color_model','cl_thresh');
    colors = single(model.color_model);
    cl_thresh = single(model.cl_thresh);
end













