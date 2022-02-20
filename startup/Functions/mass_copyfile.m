function varargout = mass_copyfile(source_dir,dest_dir)


if ~exist(dest_dir,'dir')
    mkdir(dest_dir);
end

source_list = getAllFiles(source_dir);

dest_file_list = replace(source_list,source_dir,dest_dir);
path_list = unique(cellfun(@fileparts,dest_file_list,'UniformOutput',false));
for dir_iter = 1:length(path_list)
   if ~exist(path_list{dir_iter},'dir')
       mkdir(path_list{dir_iter});
   end  
end

num_files = length(source_list);


status_vec = true(num_files,1);
message_vec = cell(num_files,1);
id_vec = cell(num_files,1);

for file_iter = 1:num_files
    
    source_file = source_list{file_iter};
    dest_file = dest_file_list{file_iter};
    
    [status_vec(file_iter),message_vec{file_iter},id_vec{file_iter}] = ...
        copyfile(source_file,dest_file,'f');
    
end

varargout{1} = status_vec;
varargout{2} = message_vec;
varargout{3} = id_vec;












