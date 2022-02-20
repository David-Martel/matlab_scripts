
clear
clc
close all

x_vals = logspace(-1.5,.5,50);
y_vals = log(x_vals);


figure(1)
clf(1)
hold on

plot(x_vals,y_vals)

plot([min(x_vals) max(x_vals)],[0 0],'k','linewidth',1)
plot(x_vals,x_vals-1,'k--','linewidth',1)

xlabel('Startle Ampl.')
ylabel('log(Startle. Ampl.)')



























