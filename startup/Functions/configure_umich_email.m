function send_email = configure_umich_email(email_switch)
% email_switch,'cubscout'
%     send_email =  'cubscoutsday@umich.edu'
% email_switch,'tbpmig'
%     send_email = 'tbp.migamma@umich.edu'
% email_switch,'shorelab'
%     send_email = 'the-shore-lab@umich.edu'

if isempty(email_switch)
    send_email=getpref('Internet','SMTP_Username');
else
    
    default_smtp='';%getpref('Internet','SMTP_Server');
    default_email='';%getpref('Internet','E_mail');
    
    default_username='';%getpref('Internet','SMTP_Username');
    default_password = '';%getpref('Internet','SMTP_Password');
    
%     [~,hostname] = system('hostname');
%     hostname(end) = [];
%     
%     username = getenv('username');
    [hostname,username] = whoami();
    

    save_file = fullfile(pwd,['hostname-' hostname '_username-' username '_default-email.mat']);
    
    email_info.smtp_server = default_smtp;
    email_info.send_email = default_email;
    email_info.user_name = default_username;
    email_info.user_password = default_password;
    
    
    if ~exist(save_file,'file')
        save(save_file,'default_smtp','default_email','default_username','default_password');
    end
    
    if ~isa(email_switch,'cell')
        email_switch = {email_switch};
    end
    
    
    if any(contains(email_switch,'@umich.edu'))
        % umich_server = resolve_hostname('smtp-private.mail.umich.edu','');
        umich_server_ip = resolve_hostname('smtp-public.mail.umich.edu','');
        if length(umich_server_ip) > 1
            smtp_server = 'smtp-public.mail.umich.edu';
        else
            smtp_server = 'smtp.mail.umich.edu';
        end
    else
%         umich_server_ip = resolve_hostname('smtp-public.mail.umich.edu','');
%         if length(umich_server_ip) > 1
%             smtp_server = 'smtp-public.mail.umich.edu';
%         else
%             smtp_server = 'smtp.mail.umich.edu';
%         end
        smtp_server = 'smtp.gmail.com';
    end
    
    %%
    if any(contains(email_switch,'cubscout'))
        send_email_pass = 'q$jZmIXkN!Zv';
        send_email =  'cubscoutsday@umich.edu';
        %smtp_server = smtp_server;
        user_name = send_email;
    elseif any(contains(email_switch,'tbpmig'))
        send_email = 'tbp.migamma@umich.edu';
        send_email_pass = 'XU@Jec!##$3G';
        %smtp_server = smtp_server;
        user_name = send_email;
    elseif any(contains(email_switch,'shorelab'))
        send_email = 'the-shore-lab@umich.edu';
        send_email_pass = '6$eWSMo2Zj9#u$g';
        %smtp_server = smtp_server;
        user_name = send_email;
    elseif any(contains(email_switch,'damartel'))
        send_email = 'damartel@umich.edu';
        send_email_pass = 'yaha4edEkuRaswe';
        %smtp_server = smtp_server;
        user_name = send_email;
    elseif any(contains(email_switch,'reset'))
        load(save_file,'default_smtp','default_email','default_username','default_password');
        send_email = default_email;
        send_email_pass = default_password;
        user_name = default_username;
        smtp_server = default_smtp;
    end
    
    
    smtp_port = num2str(465);
    
    
    setpref('Internet','SMTP_Server',smtp_server);
    setpref('Internet','E_mail',send_email);
    
    setpref('Internet','SMTP_Username',user_name);
    setpref('Internet','SMTP_Password',send_email_pass);
    
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    %props.setProperty('mail.smtp.starttls.enable','true')
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port',smtp_port);
    
end



