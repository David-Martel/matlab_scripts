function [api_url,varargout] = validate_redcap_url(varargin)


if isempty(varargin)
    redcap_server = 'redcap-p-a.umms.med.umich.edu';
else
    %logic to find redcap_server
end

ip_info = get_ipconfig;
umich_dns_found = false;
ip_info_iter = 1;
umich_dns = [];
while ~umich_dns_found && ip_info_iter <= length(ip_info)
    dns_connection = ip_info(ip_info_iter).ConnectionspecificDNSSuffix;
    if ~isempty(dns_connection) && contains(dns_connection,'med.umich.edu')
        umich_dns = strsplit(ip_info(ip_info_iter).DNSServers,',');
        umich_dns_found = true;
    end
    ip_info_iter = ip_info_iter + 1;
end

if isempty(umich_dns)
    fprintf(1,'error, must be on UM net\n')
    api_url = '';
    redcap_api_ip = '';
else
    % umich_dns = ['172.20.1.252']; % 172.20.1.244'];
    % % redcap_ip = '10.16.6.61';
    
    ip_found = false;
    ip_iter = 1;
    while ~ip_found && ip_iter<=length(umich_dns)
        [api_url,redcap_api_ip] = get_url_ip(redcap_server,umich_dns{ip_iter});
        if ~isempty(api_url)
            ip_found = true;
        else
            ip_iter = ip_iter + 1;
        end
        
    end
end
varargout{1} = redcap_api_ip;
varargout{2} = umich_dns;


function [api_url,redcap_api_ip] = get_url_ip(redcap_server,dns_server)

nslookup_str = ['nslookup -type=A ' redcap_server ' ' dns_server];

[success,response] = system(nslookup_str);
api_url = '';
redcap_api_ip = '';
if success
    fprintf(1,'Error querying OS for ip\n');
else
    response(end) = '';
    response = regexprep(response,{'[ \t]','\n{2,}'},{'','\n'});
    
    response_parts = strsplit(response,'\n');
    
    found_var = false;
    ip_iter = 1;
    while ~found_var && ip_iter<=length(response_parts)
        if contains(response_parts{ip_iter},['Name:' redcap_server])
            ip_iter = ip_iter + 1;
            redcap_api_ip = replace(response_parts{ip_iter},'Address:','');
            found_var = true;
            api_url = ['https://' redcap_server '/api/'];
        end
        ip_iter = ip_iter + 1;
    end
    
end













