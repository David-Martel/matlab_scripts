clear
clc
close all


rng(12281990);
xstuff = 1:5;
num_ani = 8;
temp_data = 5.*randn(num_ani,length(xstuff));

thresh = [30 20 10 10 20];
temp_data = temp_data + thresh;

figure(1)
clf(1)
hold on

eb = errorbar(xstuff,mean(temp_data),nansem(temp_data),'color',[0.5 0 0],'linewidth',1.1);


for row_iter = 1:size(temp_data,1)
    plot(temp_data(row_iter,:),'color',0.5+[0 0 0],'linestyle','-.');
end


xrange_plot = [min(xstuff)-1 max(xstuff)+1];
plot(xrange_plot,zeros(size(xrange_plot)),'color',[0 0 0],'linewidth',1.25);

xlim(xrange_plot);
set(gca,'xtick',xstuff);
set(gca,'xticklabel',arrayfun(@num2str,8:4:24,'uniformoutput',false))
xlabel('Freq (kHz)')
ylabel('Intensity (dB SPL)')

% ylim([-3 3])








