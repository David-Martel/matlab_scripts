function output = norm_data(input)

output = input./max(abs(input(:)));

