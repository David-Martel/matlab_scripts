

%% Configure email server
dtm = 'davidmartel07@gmail.com';
jal = 'lampenje@gmail.com';

shore_lab = 'the.khri.email@gmail.com';
shore_lab_pass = 'rwaawkldjgaauslq';


setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','E_mail',shore_lab);

setpref('Internet','SMTP_Username',shore_lab);
setpref('Internet','SMTP_Password',shore_lab_pass);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');


%% Get and update useful functions list
%populate_functions;
addpath(genpath(pwd))

%% Randomize things
rng('shuffle')

%% hardware graphics
opengl hardware

%% derp
disp('Hello David!')


