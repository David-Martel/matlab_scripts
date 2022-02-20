clear
clc
close all

Fs = 100000;
Fs_act = 48000;
seg_dur = 160/1000;
time = 0:(1/Fs):(seg_dur-1/Fs);
treat_sig = zeros(seg_dur*Fs,2);

offset = 80/1000;
treat_interval = -5/1000;



aud_dur = 10/1000;
aud_samps = aud_dur*Fs;

aud_rise = 2/1000;
aud_sig = randn(aud_samps,1);
aud_sig = aud_sig./max(abs(aud_sig));

aud_window = tukeywin(aud_samps,2*aud_rise/aud_dur);
% figure(2)
% clf(2)
% hold on

plot(aud_window)

window_audsig = aud_sig.*aud_window;
treat_sig(1:aud_samps,1) = window_audsig;

%% estim
pulse_phase_dur = 150/1e6;
pulse_sep_dur = 1/1000;

num_pulse = 3;

epulse = double(time<=pulse_phase_dur);
epulse = epulse - circshift(epulse,ceil(Fs*pulse_phase_dur));

estim = zeros(size(epulse));
for pulse_iter = 1:num_pulse
    estim = estim + epulse;
    if pulse_iter ~= num_pulse
        estim = circshift(estim,ceil(Fs*pulse_sep_dur));
    end
end

if treat_interval < 0
    stim_shift = aud_samps-Fs*treat_interval;
else
    stim_shift = Fs*treat_interval;
end

estim = circshift(estim,stim_shift);

treat_sig(:,2) = estim;

%% rotate and make pretty

treat_sig = circshift(treat_sig,Fs*offset);
time_plot = time-seg_dur/2;

yscale = 1.1;
xrange = [-10 30];
yrange = [-1 1].*yscale;

fig_handle = figure(1);
clf(1);
hold on

yyaxis left
plot(time_plot.*1000,treat_sig(:,1),'b')
ylabel('Sound Amp. (Pa)')
ylim(yrange)

yyaxis right
plot(time_plot.*1000,treat_sig(:,2),'r')
ylabel('Electrical (mA)')
ylim(yrange)

plot(xrange,zeros(size(xrange)),'k-','linewidth',1.25)
plot(zeros(size(yrange)),yrange,'k-','linewidth',1.25)

xlim(xrange)

xlabel('Time (ms)')

legend('Sound','Electrical')

ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';

saveas(fig_handle,'treatment_stim.pdf','pdf')

% xlim([0 20])
% 










