clear
clc
close all

image_filedir = pwd;

image_filenames = getAllFiles(image_filedir,...
    'findext',{'.tif','.jpg'},...
    'skipstr',{'.link','marked','.lnk'});

num_file = length(image_filenames);

% data_store = struct;
for file_iter = 1:num_file
    
    image_file = image_filenames{file_iter};
    [grp_data,marked_im] = process_image(image_file);
    
    grp_table = struct2table(grp_data,'AsArray',true);
    
    matdata_file = replace(image_file,grp_data.ext,'_data.mat');
    save(matdata_file,'grp_table','-nocompression');
    
%     xlsxdata_file = replace(image_file,grp_data.ext,'_data.xlsx');
%     writetable(grp_table,xlsxdata_file);
     
    %     if file_iter == 1
    %         data_store = repmat(grp_table,num_file,1);
    %     else
    %         data_store(file_iter,:) = grp_table;
    %     end
    
    mark_file = replace(image_file,grp_data.ext,['_marked' grp_data.ext]);
    
    if ~exist(mark_file,'file')
        imwrite(marked_im,mark_file);
    end
    
end







