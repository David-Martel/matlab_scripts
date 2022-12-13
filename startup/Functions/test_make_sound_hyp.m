clear
clc
close all

Fs = 96000;

Base_Dir = pwd;
%load('data_sound.mat','stim_times')
%load'stim_times'

back_freq = 'BBN'; %45000?

rng(12281990)
% temp_trial = (randperm(20) * 4) + 50;
% TrialTypes = transpose(temp_trial);

%% Sound pulse stimulus intensities
sound_min = 50;
sound_max = 90;
num_stim = 20;

Stim_Intensities = sound_min + randi((sound_max-sound_min),num_stim,1);

%% Interstimulus Interval times
isi_max_time = 30;
isi_min_time = 20;
isi_range = isi_max_time - isi_min_time;

stim_times = randi(isi_range,num_stim,1) + isi_min_time;


initial_wait_time = 60;
stim_times = [initial_wait_time; stim_times];

%% background sounds and startle parameters
background_atten = -100;
startle_dur = 20/1000;
start_time = 200/1000;
rise_fall_time = 2/1000;

calib_file = [];

[sound_file_name,act_stim_times,sound_data] = make_sound_hyp(Base_Dir,back_freq,Stim_Intensities,stim_times,...
    background_atten,startle_dur,start_time,rise_fall_time,calib_file);

down_sample_size = 10;

%down sample to mak
act_stim_times(1) = [];

sound_plot = sound_data(1:down_sample_size:end,1);
sound_stim_idx = round((act_stim_times+.01).*Fs./down_sample_size);

time_vec = (1:length(sound_plot))./(Fs./down_sample_size);

time_vec = time_vec-time_vec(1);

figure(1)
clf(1)
hold on

plot(time_vec,sound_plot,'r');
plot(act_stim_times,sound_plot(sound_stim_idx),'k*')

min_ticks = 0:60:max(time_vec);

set(gca,'xtick',min_ticks);
set(gca,'xticklabel',arrayfun(@num2str,min_ticks,'uniformoutput',false))

xlabel('Time (seconds)')
ylabel('Signal (arb)')




