function array = get_array_from_struct(struct_thing,var)

num_iter = length(struct_thing);
array = cell(num_iter,1);

for idx = 1:num_iter
  array{idx} = struct_thing(idx).(var); 
end