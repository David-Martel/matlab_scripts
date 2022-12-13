
zone_str = '578fd1bfd4ab1943c223d00987f2f2ac';
id_str = 'df187590eb0257d8974f1727aa8736d6';
token_str = 'p4S__C7NahnyWXef7_rrJiQLKVKWJQh22oLt-_Tl';


command_str = replace(' -X PUT "https://api.cloudflare.com/client/v4/zones/@ZONE/dns_records/@ID"',...
    {'@ZONE','@ID'},...
    {zone_str,id_str});

header_token = replace(' -H "Authorization: Bearer @TOKEN"','@TOKEN',token_str);
header_type = ' -H "Content-Type:application/json"';

machine_hostname = '"dtm-work3.radiuswired.dtmventures.com"';
machine_ip = '"2600:1700:37a8:6042:ed38:f6ec:88f2:9610"';

data_str = strcat(' --data',...
    replace(' {"type":"AAAA","name":@HOSTNAME,"content":@IP,"ttl":120,"proxied":false}',...
    {'@HOSTNAME','@IP'},{machine_hostname,machine_ip}));

curl_command = strcat('curl ',command_str,header_token,header_type,data_str);     

[status,response] = system(curl_command)

