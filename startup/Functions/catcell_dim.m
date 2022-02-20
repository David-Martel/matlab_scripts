function full_cell = catcell_dim(cell_mat,dim)


[num_row,num_col] = size(cell_mat);


if dim==1

    full_cell = cell(1,num_col);
    
    for col_iter = 1:num_col
       
        col_data = cell_mat(:,col_iter);
        
        temp_store = cell2mat(col_data);
        temp_store(isnan(temp_store))= [];
        
        full_cell{1,col_iter} = temp_store;       
    end
    
    
    
elseif dim==2
    
    full_cell = cell(num_row,1);
    
    
    
end







