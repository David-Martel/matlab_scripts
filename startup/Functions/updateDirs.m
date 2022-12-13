function success_list = updateDirs(dir_list,varargin)

ADD_PATH = false;
if any(contains(varargin,'addpath'))
    ADD_PATH = true;
end


success_list = false(length(dir_list),1);
for dir_iter = 1:length(dir_list)
    dir_item = dir_list{dir_iter};
    if ~exist(dir_item,'dir')
        success_list(dir_item) = mkdir(dir_item);
        
        if ADD_PATH
            addpath(dir_item);
        end
        
    end
end





