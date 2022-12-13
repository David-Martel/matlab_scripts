function send2gmail(address,message)



setpref('Internet','E_mail',address);
setpref('Internet','SMTP_Server','aspmx.l.google.com');

ts=clock;
t_str=sprintf('%d/%d/%d %d:%d:%.0f',ts(1),ts(2),ts(3),ts(4),ts(5),ts(6));
pc_name=getenv('computername');

body=sprintf('Sent from %s\non %s',pc_name,t_str);
sendmail(address,message,body);


end