

startup_dir = 'C:\Matlab_Startup_Dir\functions';
mml_dir = 'C:\TrialCode\MML_Tester_Matlab';

addpath(genpath(startup_dir));
addpath(genpath(mml_dir));

cd(mml_dir);

application_file = fullfile(mml_dir,'ProtocolGenerator_MML_remote.prj');

proj = openProject(application_file);






