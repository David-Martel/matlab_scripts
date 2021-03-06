function varargout = getDirs(dirName,varargin)
%additional features to add:
%recurse over cell arrays of dirs
%add directory search component
%add file extension search as part of dir, not post-dir call

p = inputParser;
%validScalarPosNum = @(x) isa(x,'char') || isstring(x);
addRequired(p,'dirName');

addOptional(p,'findstr',{}); %,@(s) isstring(s) || isa(s,'char') || isa(s,'cell'));
addOptional(p,'findext',{}); %,@(s) isstring(s) || isa(s,'char') || isa(s,'cell'));
addOptional(p,'findregex',{});

addOptional(p,'skipstr',{}); %,@(s) isstring(s) || isa(s,'char') || isa(s,'cell'));
addOptional(p,'dirdepth',inf); %,@(s) isstring(s) || isa(s,'char') || isa(s,'cell'));

addOptional(p,'skipdir',{}); %,@(s) isstring(s) || isa(s,'char') || isa(s,'cell'));

% addOptional(p,'skipstr',
parse(p,'dirName',varargin{:});


if ~isa(dirName,'cell')
    dirName = {dirName};
end

dirCounts = 0;
dirFileCounts = 0;

if p.Results.dirdepth > 0
    
%     recur_files = fullfile({dirData(:).folder},{dirData(:).name})
% 
%     
    
    dirData = dir(dirName{:});      %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    subDirs = {dirData(dirIndex).name}';
%     fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files, modified on dates
%     fileCounts = length(fileList);
  
    validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
    
    dirCounts = numel(dirData)-sum(ismember(subDirs,{'.','..'}));
    dirFileCounts = sum(~dirIndex);

    if any(validIndex)
        valid_subDirs = fullfile(dirName,subDirs(validIndex));
        
        for nextDir_iter = 1:length(valid_subDirs)                %# Loop over valid subdirectories
            %nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
            
            [subDirNames,subDirCounts,subDirFileCounts] =  getDirs(valid_subDirs(nextDir_iter),...
                'findstr',p.Results.findstr,'skipstr',p.Results.skipstr,...
                'skipdir',p.Results.skipdir,'dirdepth',(p.Results.dirdepth-1),...
                'findext',p.Results.findext,'findregex',p.Results.findregex);
            
            if isempty(subDirNames)
                dirName = subDirNames;
                dirCounts = subDirCounts;
                dirFileCounts = subDirFileCounts;
              
            else
                dirName = cat(1,dirName,subDirNames);
                dirCounts = cat(1,dirCounts,subDirCounts.*ones(length(subDirNames),1));
                dirFileCounts = cat(1,dirFileCounts,subDirFileCounts.*ones(length(subDirNames),1));
            end
            
        end
    end
    


end


varargout{1} = dirName;
varargout{2} = dirCounts;
varargout{3} = dirFileCounts;


end

































