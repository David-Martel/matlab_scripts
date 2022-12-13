function success = move_and_compress_files(data_dir,save_dir)

success = 0;

%'load data if needed'
data_previous_run = fullfile(data_dir);
if ~exist(fullfile(data_previous_run,'vid_list.mat'),'file')
    vid_list = getAllFiles(data_dir);
    save(fullfile(data_previous_run,'vid_list.mat'));
else
   load(fullfile(data_previous_run,'vid_list.mat'),'vid_list'); 
end

%remove non-video files
pts_files = contains(vid_list,'_pts');
order_files = contains(vid_list,'_order');

order_file_list = vid_list(order_files);
data_order_copy = 0;
for idx = 1:length(order_file_list)
    new_file = strrep(order_file_list{idx},data_dir,save_dir);
    make_basedir(new_file);

    data_order_copy = data_order_copy + copyfile(order_file_list{idx},new_file,'f');
    
end

if data_order_copy ~= length(order_file_list)
    sprintf('Error moving ordering data\r\n');
    success = 0;
    return
end

%pre-allocate videowriter objects
vid_list_small = vid_list(~pts_files & ~order_files);
vid_list_mp4 = cell(size(vid_list_small));

num_vid = length(vid_list_small);

for idx = 1:num_vid
    vid_file_name = vid_list_small{idx};

    save_file_name = strrep(vid_file_name,data_dir,save_dir);
    save_file_name = strrep(save_file_name,'.mat','.mp4');

    %make_basedir_local(save_file_name);

    disk_logger = VideoWriter(save_file_name, 'MPEG-4');
    disk_logger.FrameRate = 60.8553;
    vid_list_mp4{idx} = disk_logger;

end

%get video data, and save as mp4 file format
for idx = 1:num_vid
    
    data = load(vid_list_small{idx});
    names = fieldnames(data);
    
    if ~isempty(names)
        vid_data = data.(names{1});
        
        vid_writer = vid_list_mp4{idx};
        open(vid_writer);
        writeVideo(vid_writer,vid_data);
        close(vid_writer);
    end
    
    if mod(idx,10) == 0
        sprintf('finished vid: %d/%d\n',idx,num_vid);
    end
    
end


success = 1;














