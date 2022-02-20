function hash_val = GetRowMD5(data_table,var_list)

num_vars = length(var_list);
num_data = height(data_table);


hash_input = cell(num_data,1);
for var_iter = 1:num_vars
    var_name = var_list{var_iter};
    
    var_data = data_table{:,var_name};
    
    if all(isnumeric(var_data))
        var_data = arrayfun(@num2str,var_data,'uniformoutput',false);
    end
    
    hash_input = strcat(hash_input,var_data);
    
    
end

hash_val = cellfun(@(x) GetMD5(x,'Binary','hex'),hash_input,'uniformoutput',false);








