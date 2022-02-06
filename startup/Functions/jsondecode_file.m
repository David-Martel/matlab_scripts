function json_data = jsondecode_file(fname)

json_data = [];
if exist(fname,'file')

    fid = fopen(fname,'r','native','UTF-8');
    raw = fread(fid,inf,'uchar=>char')';
    fclose(fid);

    % sq_parts = strsplit(raw,{'[',']','{','}'});


    json_data = jsondecode(raw);
end







