function save_status = saveMException_json(error_struct,error_filename)

MException = [];
save_status = false;

try
    error_struct_json = jsonencode(error_struct);
    
    [error_path] = fileparts(error_filename);
    if ~exist(error_path,'dir')
        mkdir(error_path);
    end
    
    [fid,message] = fopen(error_filename,'w');
    
    if isempty(message)
        char_written = fwrite(fid,error_struct_json,'char');
        fclose(fid);
        save_status = true;
    else
        error_filename_update = replace(error_filename,'.json','.mat');
        save(error_filename_update,'error_struct','message');
    end
    
    
catch MException %lol
    error_filename_update = replace(error_filename,'.json','.mat');
    save(error_filename_update,'error_struct','MException');
end


