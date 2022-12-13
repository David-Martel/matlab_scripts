

dtm = 'davidmartel07@gmail.com';
jal = 'lampenje@gmail.com';


shore_lab = 'the-shore-lab@umich.edu';
shore_lab_pass = '8?!c$ruKrnLX';


% setpref('Internet','SMTP_Server','mail.google.com');
% setpref('Internet','E_mail',shore_lab);



setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','E_mail',shore_lab);

setpref('Internet','SMTP_Username',shore_lab);
setpref('Internet','SMTP_Password',shore_lab_pass);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

animal = 'J4';
sendmail(jal,['Operant Testing Finished: ' animal ' is done'],'Please make sure to check on guinea pig') ;


derp = datevec(now);
derp(5) = derp(5)+10;

derp = datestr(derp);
disp(['Derp time: ' derp])





