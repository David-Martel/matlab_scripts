function varargout = getAllFiles(dirName,varargin)

p = inputParser;
%validScalarPosNum = @(x) isa(x,'char') || isstring(x);
addRequired(p,'dirName');

addOptional(p,'findstr',{}); %,@(s) isstring(s) || isa(s,'char') || isa(s,'cell'));
addOptional(p,'skipstr',{}); %,@(s) isstring(s) || isa(s,'char') || isa(s,'cell'));
addOptional(p,'dirdepth',inf); %,@(s) isstring(s) || isa(s,'char') || isa(s,'cell'));

addOptional(p,'dirstr',{}); %,@(s) isstring(s) || isa(s,'char') || isa(s,'cell'));

% addOptional(p,'skipstr',
parse(p,'dirName',varargin{:});

fileList = {};
fileDate = [];
fileSize = [];
emptyDirs = dirName;

if isa(dirName,'cell')
    dirName = dirName{:};
end

if p.Results.dirdepth > 0
    
    dirData = dir(dirName);      %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    
    fileList_temp = {dirData(~dirIndex).name}';  %'# Get a list of the files, modified on dates
    fileDate = [dirData(~dirIndex).datenum]';
    fileSize = [dirData(~dirIndex).bytes]';
    
    %% identify files to keep
    if ~isempty(fileList_temp)
        
        if ~isempty(p.Results.dirstr)
            if ~contains(dirName,p.Results.dirstr,'ignorecase',true)
                rm_idx = true(size(fileList_temp));
            else
                rm_idx = false(size(fileList_temp));
            end
        else
            rm_idx = false(size(fileList_temp));
        end
        
        if ~all(rm_idx)
            rm_idx = rm_idx | contains(fileList_temp,[p.Results.skipstr {'.ini'}],'ignorecase',true); % | ...
            if ~isempty(p.Results.findstr)
                %         findstrs = p.Results.findstr;
                %         and_findstrs = contains(findstrs,'@');
                %
                rm_idx = rm_idx | ~contains(fileList_temp,p.Results.findstr,'ignorecase',true);
            end
            
            fileList = fullfile(dirName,fileList_temp);
            
            % remove files/folders w/o required elements
            if any(rm_idx)
                fileList(rm_idx) = [];
                fileDate(rm_idx) = [];
                fileSize(rm_idx) = [];
            end
        else
            fileList = {};
            fileDate = [];
            fileSize = [];
        end
        emptyDirs = {};
    else
        
    end
    
    
    %% move forward and recurse
    subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
    validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
    %#   that are not '.' or '..'
    
    if any(validIndex)
        valid_subDirs = fullfile(dirName,subDirs(validIndex));
        
        for nextDir = valid_subDirs                %# Loop over valid subdirectories
            %nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
            
            [subfileList, subDateList, subSizeList, subEmptyDirs] =  getAllFiles(nextDir,...
                'findstr',p.Results.findstr,'skipstr',p.Results.skipstr,...
                'dirstr',p.Results.dirstr,'dirdepth',(p.Results.dirdepth-1));
            
            if isempty(fileList)
                if ~isempty(subfileList)
                    fileList = subfileList;
                    fileDate = subDateList;
                    fileSize = subSizeList;
                else
                    emptyDirs = cat(1,emptyDirs,subEmptyDirs);
                end
            else
                if ~isempty(subfileList)
                    fileList = cat(1,fileList,subfileList);  %# Recursively call getAllFiles
                    fileDate = cat(1,fileDate,subDateList);
                    fileSize = cat(1,fileSize,subSizeList);
                else
                    emptyDirs = cat(1,emptyDirs,subEmptyDirs);
                end
            end
            
        end
        
    end
    
end

varargout{1} = fileList;
varargout{2} = fileDate;
varargout{3} = fileSize;

varargout{4} = emptyDirs;

end

































