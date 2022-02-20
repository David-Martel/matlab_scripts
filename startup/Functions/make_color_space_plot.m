clear
clc
close all
base_dir = pwd;

%get video data
data_path = fullfile(base_dir,'\data\Jul 05 2019\S3\three_six\PPN');
data_file = 'S3_three_six_PPN_Trial_1.mp4';
vid_file = fullfile(data_path,data_file);

%get color model
color_model = 'S3_purple_green_model.mat';
color_file = fullfile(base_dir,color_model);

load(color_file,'color_model','color_labels');

[vid_data,frame_size,num_frames] = read_mp4(vid_file);

frame_num = 15;
frame_temp = vid_data(:,:,:,frame_num);













