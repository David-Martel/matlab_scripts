clear
clc
close all
drawnow;

data_dir = '\\umms-sushore-win.turbo.storage.umich.edu\umms-sushore\H_animals';

local_dir = 'H:\BigTemp';


file_list = getAllFiles(data_dir);


vid_str = '.mp4';
data_str = '.mat';
order_str = '_presentation_order.mat';


file_list(~contains(file_list,{vid_str,data_str})) = [];

order_idx = contains(file_list,order_str);
pres_files = file_list(order_idx);
vid_files = file_list(~order_idx);

target_list = replace(vid_files,{data_dir, data_str},{local_dir,vid_str});

part_list = cellfun(@fileparts,target_list,'uniformoutput',false);
part_list = unique(part_list);
for iter = 1:length(part_list)
    
    if ~exist(part_list{iter},'dir')
        mkdir(part_list{iter});
    end
    
end

for iter = 1:length(pres_files)
    pres_file = pres_files{iter};
    pres_file_new = replace(pres_file,data_dir,local_dir);
    success = copyfile(pres_file,pres_file_new,'f');
end

%% write videos to disk
vid_writer_array = cell(length(target_list),1);
for idx = 1:length(target_list)
    
    if ~exist(target_list{idx},'file')
        disk_logger =  VideoWriter(target_list{idx},'MPEG-4');
        disk_logger.FrameRate = 60.8553;
        vid_writer_array{idx} = disk_logger;
    end
    
end

num_vid = length(vid_files);
for idx = 1:num_vid
    source_file = vid_files{idx};
    
    if ~isempty(vid_writer_array{idx})
        try
            varnames = whos('-file',source_file);
            
            varname = varnames.name;
            
            vid_data = load(source_file);
            
            vid_data = vid_data.(varname);
            
            open(vid_writer_array{idx});
            writeVideo(vid_writer_array{idx},vid_data);
            close(vid_writer_array{idx});
            
        catch
            disp(['Error on: ' num2str(idx) '/' num2str(num_vid)]);
        end
        
    else
        
        disp(['File exists: ' num2str(idx) '/' num2str(num_vid)]);
        
    end
    if idx == 1
        derp = 5;
    end
    
end











