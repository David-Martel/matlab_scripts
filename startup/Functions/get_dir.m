function dir_var = get_dir(filename)

splits = strsplit(filename,'\');
splits(end) = [];

dir_var = fullfile(splits{:});









