function hash_value = getFileHash(filename)


powershell_cmd = 'powershell -command "(Get-FileHash %s -Algorithm SHA1).Hash"';
source_cmd = sprintf(powershell_cmd,filename);

[status,response] = system(source_cmd);

if ~status
    hash_value = response;
%     response = replace(response,{char(32)},'');
%     
%     resp_parts = strsplit(response,newline);
%     hash_val = contains(resp_parts,'Hash:');
%     hash_str = resp_parts{hash_val};
%     
%     hash_value = replace(hash_str,'Hash:','');
%     
else
    hash_value = nan;
    %error(['Error computing hash on: ' filename])
end









