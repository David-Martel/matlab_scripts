function date_time_part = get_datetime(file_name)

file_parts = strsplit(file_name,'_');

date_time_part = strcat(file_parts{2},'_',file_parts{3});
date_time_part(1) = [];





