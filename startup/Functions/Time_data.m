clear 
clc 

base_dir='G:\Shared drives\[KHRI Shore] GPVideo\Data\Y animals';

fileList=getAllFiles(base_dir);
Acq_files=fileList(contains(fileList,'AcquisitionData'));

fram_rate=120;
for j=1:length(Acq_files)
    
load(Acq_files{j})
disp([num2str(j) '- ' Acq_files{j}])
        
file_name=strsplit(Acq_files{j},'AcquisitionData_');

file_dir=file_name{1};
file_dir=file_dir(1:end-1);

file_name=file_name{2};
file_name=strsplit(file_name,'.mat');
file_name=file_name{1};

session_num=length(Acqu_data.StartAquisition);

act_strt_time=zeros(session_num,1);
stim_on_time=zeros(session_num,1);

for i = 1:session_num
act_strt_time(i,1)=Acqu_data.StartAquisition(i).RelativeToSound;
stim_on_time(i,1)=Acqu_data.StimulusOnset(i).Precalculated;
end

rec_time=stim_on_time-act_strt_time;

time_data= [(1:session_num)' act_strt_time,stim_on_time,rec_time,floor(rec_time*120)]; 
time_data_tbl=array2table(time_data,'VariableNames',{'Session','Act Acqu Start Time','Stim On Time','Time Difference','Frame'});

file_name=['time_data_tbl_' file_name]; 
file_name=fullfile(file_dir,file_name);

save(file_name,'time_data_tbl')
end