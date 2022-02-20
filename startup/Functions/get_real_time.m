function t= get_real_time(metadata)
%datetime.setDefaultFormats('default','yyyy-MM-dd hh:mm:ss.SSSSSS')
for i= 1:length(metadata)
Y=metadata(i).AbsTime(1);
M=metadata(i).AbsTime(2);
D=metadata(i).AbsTime(3);
h=metadata(i).AbsTime(4);
minu=metadata(i).AbsTime(5);
sec=metadata(i).AbsTime(6);
dt(i)=datetime(Y,M,D,h,minu,sec);
end
t=posixtime(dt);
end 