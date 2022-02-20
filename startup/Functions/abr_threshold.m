function data_with_result = abr_threshold(data)
%
%

%%
% ff = 'U:\2Data\ABRs\Calvin\export\SC7.txt';
% data = ARF2mat(ff,'verbose',1)

groups = data.groups(data.groups.record_numbers>2,:);
records = data.records(data.records.n_averages>100&ismember(data.records.index,groups.index),:);

RMS = rms(records.waveform,2);

[a,b,c]=unique(records.index);
thr=NaN(size(a));
for i=1:length(a)
%     clf
    idx = c==i;
    io_fun = [records.level(idx),RMS(idx)];
    io_fun = sortrows(io_fun,1);
%     while io_fun(1,2)>io_fun(2,2)
%         io_fun(1,:)=[];
%     end

%     io_fun(1:find(diff(io_fun(:,2))<0)+1,:)=[];
    
%     plot(io_fun(:,1),normalize01(io_fun(:,2)),'o');hold on
    if size(io_fun,1)>1
    f = fit(io_fun(:,1),normalize01(io_fun(:,2)),'smoothingspline');
    x=0:1:90;
    y=f(x);
%     plot(x,y)
    crit=0.05;
    tt=x(abs(y-crit)==min(abs(y-crit)));
    thr(i) = min(tt);
    end
%     line([thr thr],get(gca,'ylim'))
%     waitforbuttonpress
end


thr_list = NaN(size(data.groups.index));
thr_list(ismember(data.groups.index,a))=thr;
if ismember('threshold',data.groups.Properties.VariableNames)
    data.groups.threshold=[];
end

data_with_result=data;
data_with_result.groups=[data.groups array2table(thr_list,'VariableNames',{'threshold'})];

end
