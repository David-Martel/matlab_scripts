function computer_name = get_hostname()

[~,computer_name] = system('hostname');
computer_name(end) = [];







