function ipaddr = resolve_hostname(hostname,dns_server)

ipaddr = {''};


instrs = {hostname,dns_server};
instrs = instrs(~cellfun('isempty',instrs));
query_str = strjoin(cat(2,'nslookup',instrs),' '); %sprintf('nslookup %s %s',hostname,dns_server);

[status,response] = system(query_str);
response(end) = '';

if ~status
%     response = regexprep(response,'\s+','\n')
% response = regexprep(response,'\n[w]|\n?\s+',',')
% strsplit(response,{newline,},'CollapseDelimiters',true,)

    ipaddr4 = regexpi(response,'(\d{1,4}[\.]?[^:|^\n]){3,4}','match');
    ipaddr6 = regexpi(response,'([a-f|\d]{1,4}[:]{1,2}[^\.|^\n]){2,8}','match');

    if ~isempty(ipaddr4) || ~isempty(ipaddr6)
        ipaddr = cat(2,ipaddr4,ipaddr6);
        ipaddr = ipaddr(~cellfun('isempty',ipaddr));
    end
end













