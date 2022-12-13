function success = make_basedir(file)

success = 0;

file_derp = strrep(file,'\\',filesep);
fileparts = strsplit(file_derp,filesep);
fileparts(end) = [];

filepath = fullfile(fileparts{:});

if ~exist(filepath,'dir')
    mkdir(filepath);
end










