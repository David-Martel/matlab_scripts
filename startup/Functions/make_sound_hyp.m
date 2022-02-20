
%% Construct Audio Stimulus
function [sound_file_name,varargout] = make_sound_hyp(Base_Dir,back_freq,Stim_Intensities,stim_times,...
    background_atten,startle_dur,start_time,rise_fall_time,calib_file)


%get calibration data
if ~isempty(calib_file)
    load(calib_file,'max_output');
    % Get calibration data
    % calib_data = import_calib_file(calib_file,'Sheet1');
    % intens = calib_data.Intensity(calib_data.back_freq==back_freq); %del
    % band_ave = mean(intens); %del
    % speaker_level_BBN = mean(calib_data.Intensity(calib_data.back_freq=='BBN'));
    
else
    max_output = 90;%Assume this for sake of argument; change this depending on headphone type
end

num_sound_channel = numel(max_output);

Startle_DB = db2mag(max_output-Stim_Intensities);

%% build sounds
%---------- startle pulse
Fs = 96000;
[fmin,fmax] = get_noise_band_range(back_freq);

startle_pulse = make_noise_band(fmin,fmax,Fs,ceil(startle_dur));
startle_samples = (Fs*start_time):(Fs*(start_time+startle_dur));


rise_fall_func = tukeywin(length(startle_samples),rise_fall_time/startle_dur);

startle_noise = startle_pulse(startle_samples,1);
startle_noise = startle_noise.*rise_fall_func;


%---------- background sound
back_noise_long = make_noise_band(fmin,fmax,Fs,1);
test_length_sec = ceil(sum(stim_times)*1.1);

long_noise = repmat(db2mag(background_atten).*back_noise_long...
    ,test_length_sec,1);

%% Embed trials in background noise
startle_pulse_time = cumsum(stim_times);
startle_pulse_sample = startle_pulse_time.*Fs;


if num_sound_channel == 1
    
    for idx = 1:length(Startle_DB)
        
        startle = Startle_DB(idx).*(startle_noise);
        
        startle_idx = startle_pulse_sample(idx+1):(startle_pulse_sample(idx+1)+length(startle))-1;
        long_noise(startle_idx,1) = startle;
        
    end
    
    %send data to each channel
    long_noise = repmat(long_noise,1,4);
elseif num_sound_channel == 4 %quad channel with unique output values
    
    long_noise = repmat(long_noise,1,num_sound_channel);
    startle_pulse = startle_pulse(:,1); %forces signal to be a column
    
    startle_pulse = repmat(startle_pulse,1,num_sound_channel);
    
    for idx = 1:length(Stim_Intensities)
        Startle_DB = db2mag(max_output - Stim_Intensities(idx));
        startle_noise = Startle_DB.*(startle_pulse);
        startle_noise = startle_noise(startle_samples,:);
        
        startle_idx = startle_pulse_sample(idx+1):(startle_pulse_sample(idx+1)+length(startle_noise))-1;
        long_noise(startle_idx,:) = startle_noise;
        
    end
    
end

%overall attenuation scalar
long_noise = long_noise./(max(abs(long_noise(:)))); %sets value range to be +/- 1 numerical values

file_name_label = sprintf('%s_%d_%d',back_freq,min(Stim_Intensities),max(Stim_Intensities));

%Write Audio File (END)
file_name = sprintf('%s_fast_protocol.wav',file_name_label);
sound_file_name = fullfile(Base_Dir,file_name);
audiowrite(sound_file_name,long_noise,Fs);

varargout{1} = startle_pulse_time;
varargout{2} = long_noise;

















