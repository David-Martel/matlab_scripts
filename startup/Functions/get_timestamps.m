clear
clc
close all

base_dir = 'F:\Temp\Reanalysis';
helper_dir = fullfile(base_dir,'helper');
addpath(helper_dir);

ani = 'Y1';
date = 'Feb-16-2021';

data_dir = fullfile(base_dir,ani,date);
file_list = getAllFiles(data_dir);
time_files = file_list(~contains(file_list,{'.mp4','_data.mat'}));

acq_dir = fullfile(base_dir,[ani(1) ' animal'],date);
acq_files = getAllFiles(acq_dir);

[~,acq_file_parts] = fileparts(acq_files);
acq_file_parts = replace(acq_file_parts,'AcquisitionData_','');


test_idx = 7;

test_acq_fileparts = strsplit(acq_file_parts{test_idx},'_');
test_acq_fileparts = cellfun(@keepDigits,test_acq_fileparts,'uniformoutput',false);

test_acq_file = acq_files{test_idx};

test_acq_idx = contains(time_files,test_acq_fileparts{1}) & ...
    contains(time_files,test_acq_fileparts{2});

test_files = time_files(test_acq_idx);

[~,~,~,~,trial_idx] = cellfun(@(x) get_test_info_new(x,ani(1)),...
    test_files,'uniformoutput',false);
trial_idx = cell2mat(trial_idx);

[trial_idx,sort_idx] = sort(trial_idx,'ascend');

test_files = test_files(sort_idx);

load(test_acq_file,'Acqu_data')

start_time = Acqu_data.StartAudio; %start of audio file
num_stim = length(test_files); %when each pulse should occur

stim_times = nan(num_stim,1);
for stim_iter = 1:num_stim
    stim_times(stim_iter) = Acqu_data.StimulusOnset(stim_iter).Precalculated;
end

figure(test_idx)
clf(test_idx)

subplot(1,2,1)
hold on
stim_start_store = nan(num_stim,1);

for file_iter = 1:num_stim
    
    test_file = test_files{file_iter};
    %test_file = fullfile(base_dir,ani,date,file_name);
    load(test_file,'metadata','tsdata');
    
    meta_times = nan(length(metadata),1);
    for frame_iter = 1:length(metadata)
        meta_times(frame_iter) = posixtime(datetime(metadata(frame_iter).AbsTime));
    end
    
    meta_norm = meta_times-start_time;
    meta_norm_start = meta_norm(1);
    
    stim_time_start = stim_times(file_iter)-meta_norm_start;
    
    plot(meta_norm-meta_norm_start,tsdata,'b','linewidth',1.2)
    plot(stim_time_start*ones(2,1),[0 4],'k')
    stim_start_store(file_iter) = stim_time_start;
    
end
title('Frame TS vs Sound Presentation Time')

xlabel('Trial Time (sec)')
ylabel('Frame Time (sec)')


subplot(1,2,2)
hold on

scatter(1:num_stim,stim_start_store,'k*')
ylim([0 4])

xlabel('Trial')
ylabel('Time re Cam Start (time)')
title('Time of sound pulse relative to frame time')










