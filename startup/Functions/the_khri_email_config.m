function user_email = the_khri_email_config()


user_email = 'the.khri.email@gmail.com';
user_pass = 'zvqzvqufumyjbppd';


setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','E_mail',user_email);

setpref('Internet','SMTP_Username',user_email);
setpref('Internet','SMTP_Password',user_pass);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

