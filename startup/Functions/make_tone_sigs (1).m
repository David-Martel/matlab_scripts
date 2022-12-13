clear
clc
close all

sig_dur = 60*3;
fs = 96000;
f_array = 500:100:800;

time_vec = 0:(1/fs):(sig_dur);
time_vec(end)  =[];

sine_sig = zeros(length(time_vec),4);
for idx = 1:4

    sine_sig(:,idx) = sin(2.*pi.*f_array(idx).*time_vec);
    


end

audiowrite('derp.wav',sine_sig,fs);











