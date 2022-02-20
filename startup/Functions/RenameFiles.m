% Get all files in the current folder
files = dir('*.csv');
% Loop through each
for id = 1:length(files)
    
    % Get the file name (minus the extension)
    [~, old] = fileparts(files(id).name);
    
    new = [old 'Hz'];
    movefile([old '.csv'], [new '.csv'])
    
end


%   rename(files(id), old, new)