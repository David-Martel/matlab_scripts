function study_data = variable2decimal(study_data,varargin)

var_list_original = study_data.Properties.VariableNames;

if ~isempty(varargin)
    mod_list = varargin{1};
    var_list = var_list_original(ismember(var_list_original,mod_list));
else
    var_list = var_list_original;
end

num_data = height(study_data);

for var_iter = 1:length(var_list)
    var = var_list{var_iter};
    
    var_data = study_data{:,var};
        
    if isa(var_data,'cell')
        digit_idx = cellfun(@(x) all(containsDigits(x)),var_data,'uniformoutput',true);
        if sum(digit_idx) == num_data
            var_data_num = abs(str2double(var_data));
            
            study_data(:,var) = [];
            study_data(:,var) = table(var_data_num);
        end
    end
end

study_data = study_data(:,var_list_original);
















