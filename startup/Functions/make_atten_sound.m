
clear
clc
close all


fs = 48000;

stim_dur = 5;

noise_sound = randn(stim_dur.*fs,1);
noise_sound = noise_sound./max(abs(noise_sound));

sound_scalar = .1;

noise_sound = noise_sound.*sound_scalar;

db = -12;

noise_quite = db2mag(db).*noise_sound;

noise_quite2 = db2mag(-6).*noise_quite;


wav_file = [noise_sound; noise_quite2];

sound_file = 'db_sound2.wav';

audiowrite(sound_file,wav_file,fs)









