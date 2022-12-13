function files_equivalent = compare_files(file1,file2,varargin)
%files_equivalent = compare_files(file1,file2) returns true if two files
%have identical hash values. Default hash selected is MD5. Function
%utilizes Microsoft Windows CertUtil function to compute hash values.
%Documentation can be found at: 
%https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/certutil#BKMK_hashfile
files_equivalent = false;

if isempty(varargin)
    hash_type = 'SHA1';
else
    hash_type = varargin{1};
end


hash_command = 'CertUtil -hashfile "%s" %s';


hash_com1 = sprintf(hash_command,file1,hash_type);
[status1,response1] = system(hash_com1);

if ~status1
    hash_value1 = extract_hash(response1);
else
    files_equivalent = nan;
    return
end

hash_com2 = sprintf(hash_command,file2,hash_type);
[status2,response2] = system(hash_com2);

if ~status2
    hash_value2 = extract_hash(response2);
else
    files_equivalent = nan;
    return
end

files_equivalent = strcmp(hash_value1,hash_value2);



function hash_value = extract_hash(response)

response_parts = strsplit(response,'\n');
hash_value = response_parts{2};


















