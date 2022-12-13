function file_size = filesize_func(file_items)
%filesize_func = @(x)(dir(x).bytes)

file_size = nan;

if iscell(file_items)

    file_size = cellfun(@(x)(dir(x).bytes),file_items,'uniform',true);

elseif ischar(file_items) || isstring(file_items)

    file_size = (dir(file_items).bytes);

end
