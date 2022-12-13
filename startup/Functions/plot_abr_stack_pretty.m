
clear
clc
close all

intens = 90:-10:0;
num_inten = length(intens);

time_pts = 250;

%assumption: sample data is ordered such that each row == ABR trace from a
%given intensity, and each column is the corresponding time value, eg,
%ABR(t).

sample_data = randn(num_inten,time_pts);
sample_data2 = randn(num_inten,time_pts);


figure(1)
clf(1)
hold on


max_scale = max(abs(sample_data),[],2);

sample_data_scale = sample_data./max_scale(1);
sample_data2_scale = sample_data2./max_scale(1);

time_vec = 0:(time_pts-1);

for inten_iter = 1:2:num_inten
   
    plot(time_vec,intens(inten_iter)./10 + sample_data_scale(inten_iter,:)./(inten_iter),'r');
    plot(time_vec,intens(inten_iter)./10 + sample_data2_scale(inten_iter,:)./inten_iter,'b');   
    
end

ylim([-0.5 9.5]);
set(gca,'ytick',0:9)
set(gca,'yticklabel',arrayfun(@(x) num2str(10*x,'%d'),0:9,'uniformoutput',false))

xlabel('Time (samples)')
ylabel('Intensity (dB SPL)')
legend('Click','Chirp')




















