function [hostname,username] = whoami()

[status,response] = system('whoami');

if ~status
    response(end) = '';
    [strparts,strother] = strsplit(response,filesep);
    hostname = strparts{1};
    username = strparts{2};
    

else
    hostname = '';
    username = '';
end


