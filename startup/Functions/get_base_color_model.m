function [colors,cl_thresh] = get_base_color_model(color_dir)

data = load(fullfile(color_dir,'color_model_main.mat'),...
    'color_model','gr_mdl','num_clust','num_shade');
color_model = data.color_model;
gr_mdl = data.gr_mdl;
num_clust = data.num_clust;
num_shade = data.num_shade;

%update color model with new colors
num_clust = num_clust+2;
num_shade = num_shade+2;

colors = [[210 240 210];[220 250 220]; color_model; gr_mdl;...
    [108 141 101];[186 241 183]];

color_labels = (num_clust+(1:num_shade));
cl_thresh = min(color_labels);


colors = single(colors);
cl_thresh = single(cl_thresh);