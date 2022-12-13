function dtm_machine = get_pgp_dtm(varargin)

if ~isempty(varargin)
    pgp_key = varargin{1};
else
    pgp_key = 'C:\Users\david\.pgp\cryptup-davidmartel07gmailcom.key';
end

pgp_key_hash_opts = struct;
pgp_key_hash_opts.Method='SHA-256';
pgp_key_hash_opts.Format='hex';
pgp_key_hash_opts.Input='file';

key_hash = DataHash(pgp_key,pgp_key_hash_opts);

%sha-256
hash_list_256 = {'8d94335374c424ec7c2872ac7b07f1fc4b98b73f3f05757d777ec2acb33a499e'};

%sha-512
hash_list_512 = {'eac27dc408a335ab98747418b7003d17251f6ef6a75e4382542eec1ebcb48c290bb9953df226bcc3eabef4e82bf7fe990d54bee15974b394c0a2badbaa9262b1'};

hash_list = {hash_list_256,hash_list_512};

find_hash = @(x)ismember(key_hash,x);

if any(cellfun(find_hash,hash_list))
    dtm_machine = true;
else
    dtm_machine = false;
end






