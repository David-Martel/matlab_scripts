function pooled_data = pool_cells(cell_data)

pooled_data = [];
if ~isempty(cell_data)
    
    for iter = 1:length(cell_data)
        data = cell_data{iter};
        if isrow(data)
            data = data';
        end
        pooled_data = [pooled_data; data];
    end
else
    
end