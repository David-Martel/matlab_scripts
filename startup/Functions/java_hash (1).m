function str = java_hash(in)

% Get a bytestream from the input. Note that this calls saveobj.
if isfile(in)
    inbs = get_bytestream(in);
elseif ~ischar(in)
    inbs = hlp_serialize(in);
end

% Create hash using Java Security Message Digest.
md = java.security.MessageDigest.getInstance('MD5');
md.update(inbs);

% % Convert to uint8.
% d = ;

% Convert to a hex string.
str = sprintf('%02x',typecast(md.digest, 'uint8'));
% str = lower(str(:)');

end

function inbs = get_bytestream(in)
    FID = fopen(in, 'r');
    inbs   = fread(FID, inf, 'uint8=>uint8');
    fclose(FID);
end
