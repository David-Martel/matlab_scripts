function [status_list,varargout] = createZipFolder(base_dir,varargin)
%varargout{1} = dir_list;
% varargout{2} = zip_files;
% varargout{3} = file_list;

VERBOSE = false;
if any(contains(varargin,'verbose','IgnoreCase',true))
    VERBOSE = true;
end

if any(contains(varargin,'filelist','IgnoreCase',true))
    filelist_idx = contains(varargin,'filelist')+1;
    file_list = varargin{filelist_idx};
else
    %use imfinfo to get useful meta data
    file_list = getAllFiles(base_dir);
end
%remove local directory, desktop files from copy
remove_items = {'.ini'};
file_list(contains(file_list,remove_items)) = [];

%unique list of directories
dir_list = unique(cellfun(@fileparts,file_list,'uniformoutput',false));

dir_depth = cellfun(@comp_folder_depth,dir_list) + 1; %files have their own
dir_depth_file_list = cellfun(@comp_folder_depth,file_list);

%% make backup zip files first, or omit to process data
zip_dir = [base_dir '_ZIP'];
if ~exist(zip_dir,'dir')
    mkdir(zip_dir);
end

hold_str = '@HOLD@';
zip_files = replace(dir_list,base_dir,hold_str);

%any files/folders with underscores and spaces get converted into dashes
zip_files = replace(zip_files,{' ','_'},'-');

%folder seperators become underscores--> reduces branch complexity
replace_items = {filesep};
replaced_with = {'_'};
zip_files = replace(zip_files,replace_items,replaced_with);

zip_files = replace(zip_files,[hold_str '_'],[zip_dir filesep]);
%zip_files = cellfun(@(x) strcat(x,'.zip'),zip_files,'uniformoutput',false);
zip_files = strcat(zip_files,'.zip');

%% loop over file, folder list and add entries to zip files
num_dirs = length(dir_list);
status_list = false(num_dirs,1);

for zip_iter = 1:num_dirs
    zipped_dir = dir_list{zip_iter};
    
    zipped_dir_depth = dir_depth(zip_iter);
    
    file_idx = contains(file_list,[zipped_dir filesep]) ...
        & dir_depth_file_list==zipped_dir_depth;
    zip_file_list = file_list(file_idx);
    
    zipped_file = zip_files{zip_iter};
    
    if ~exist(zipped_file,'file')
        try
            zip(zipped_file,zip_file_list);
            status_list(zip_iter) = true;
            
            if VERBOSE
                %disp(['Fin: ' num2str(zip_iter) '/' num2str(num_dirs)])
                fprintf(1,'Fin: %d/%d\n',zip_iter,num_dirs);
            end
        catch MException
            derp = 5;
            if VERBOSE
                fprintf(1,'Error: %d/%d\n',zip_iter,num_dirs);
            end
        end
    else
        fprintf(1,'Exists: %d/%d\n',zip_iter,num_dirs);
    end
end

varargout{1} = dir_list;
varargout{2} = zip_files;
varargout{3} = file_list;



