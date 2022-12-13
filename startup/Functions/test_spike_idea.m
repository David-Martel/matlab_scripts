clear
clc
close all

fs = 500;

thresh1 = 50;
time1 = 2;

thresh2 = 50; %40;
time2 = 1;

v1_reset = 0;%.01;
v2_reset = 0;%.01;

iapp = zeros(fs,1);
time = 1:fs;

ton = 100;
toff = 300;


stim_time = time>=ton & time<=toff;
iapp(stim_time) = .1;

noise_val = .5;

%% simulate spiking
[v1,v2,v1_spike,v2_spike] = sim_spikes(fs,v1_reset,v2_reset,...
    thresh1,thresh2,time1,time2,noise_val,time,iapp);

v1_evoked_rate = sum(v1_spike>=ton & v1_spike<=toff)./(toff-ton);
v2_evoked_rate = sum(v2_spike>=ton & v2_spike<=toff)./(toff-ton);

figure(1)
clf(1)

yyaxis left
hold on
plot(time,v1,'b')
plot(time,v2,'r')

plot(time,thresh2.*ones(size(time)),'r--','linewidth',2);
plot(time,thresh1.*ones(size(time)),'b--','linewidth',2);

ylim([0 1.1.*max([thresh1 thresh2])])

xlabel('Time (samps)')
ylabel('Voltage')

yyaxis right
plot(time,iapp./max(abs(iapp)),'k','linewidth',2);
ylim([0 1.1])
ylabel('Current')

ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';

legend(['V1 (noise=' num2str(noise_val) '): ' num2str(v1_evoked_rate)],...
    ['V2: ' num2str(v2_evoked_rate)])











