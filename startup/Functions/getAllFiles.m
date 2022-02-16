function varargout = getAllFiles(dirName,varargin)
%additional features to add:
%recurse over cell arrays of dirs
%add directory search component
%add file extension search as part of dir, not post-dir call
try
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

    proc_vars = fieldnames(p.Results);
    proc_vals = struct2cell(p.Results);
    pass_data = cell(1,2*length(proc_vars));
    pass_data(1:2:end) = proc_vars;
    pass_data(2:2:end) = proc_vals;




    %%
    fileList = {};
    fileDate = [];
    fileSize = [];
    emptyDirs = dirName;

    if isa(dirName,'cell')
        if length(dirName) > 1

            for iter = 1:length(dirName)

                [iterFileList,iterFileDate,iterFileSize] = getAllFiles(...
                    dirName{iter},pass_data{:});

                fileList = cat(1,fileList,iterFileList);
                fileDate = cat(1,fileDate,iterFileDate);
                fileSize = cat(1,fileSize,iterFileSize);

            end

        else
            dirName = dirName{:};
        end
    end

    if p.Results.dirdepth > 0

        %     recur_files = fullfile({dirData(:).folder},{dirData(:).name})
        %
        %

        if ~isempty(p.Results.findext)
            dirData = dir(fullfile(dirName,'**',['*' p.Results.findext]));
        else
            dirData = dir(dirName);      %# Get the data for the current directory
        end
        dirIndex = [dirData.isdir];  %# Find the index for directories
        subDirs = {dirData(dirIndex).name}';

        fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files, modified on dates
        fileDate = [dirData(~dirIndex).datenum]';
        fileSize = [dirData(~dirIndex).bytes]';
        fileDirs = {dirData(~dirIndex).folder}';  %# Get a list of the subdirectories

        %% identify files to keep
        if ~isempty(fileList)

            rm_idx = false(size(fileList));

            if ~isempty(p.Results.skipdir)
                rm_idx = rm_idx | contains(fileDirs,p.Results.skipdir,'ignorecase',true);
            end

            if ~isinf(p.Results.dirdepth)
                base_dirdepth = numel(strfind(dirName,filesep));
                file_dirdepth = cellfun('length',strfind(fileDirs,filesep));
                rm_idx = rm_idx | (file_dirdepth-p.Results.dirdepth>=base_dirdepth);
            end

            if ~all(rm_idx)

                %% process files
                rm_idx = rm_idx | contains(fileList,...
                    [p.Results.skipstr {'.ini'}],'ignorecase',true); % | ...
                if ~isempty(p.Results.findstr)
                    rm_idx = rm_idx | ~contains(fileList,p.Results.findstr,'ignorecase',true);
                end

                if ~isempty(p.Results.findregex)
                    rm_idx = rm_idx | cellfun('isempty',regexpi(fileList,p.Results.findregex,'match','once'));
                end



                %% process directories
                fileList = fullfile(fileDirs,fileList);

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

        validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
        %     if ~isempty(subDirs)
        %         validIndex = validIndex |
        %     end
        %#   that are not '.' or '..'

        if any(validIndex)
            valid_subDirs = fullfile(dirName,subDirs(validIndex));

            for nextDir = valid_subDirs                %# Loop over valid subdirectories
                %nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path

                [subfileList, subDateList, subSizeList, subEmptyDirs] =  getAllFiles(nextDir,...
                    'findstr',p.Results.findstr,'skipstr',p.Results.skipstr,...
                    'skipdir',p.Results.skipdir,'dirdepth',(p.Results.dirdepth-1),...
                    'findext',p.Results.findext,'findregex',p.Results.findregex);

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

catch MException
    derp = 5;
end


    varargout{1} = fileList;
    varargout{2} = fileDate;
    varargout{3} = fileSize;

    varargout{4} = emptyDirs;

end
































