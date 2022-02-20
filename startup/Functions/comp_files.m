% Intermediate task: write a function that takes two inputs (source, target) 
% and copies all files from source to target, 
% skipping files already in target
% Mirror the folder structure from source in target
% Useful functions:
% Fileparts
% getAllFiles
% Copyfile
% Replace
% cellfun, exist, isempty
% Only copy these filetypes: Extension types: .m, .mat, .mp4 
% exist('NAME','file') checks for files or folders.
% exist('NAME','dir') checks only for folders.

function comp_files(src,trg)
[fileListInSrc,~] = getAllFiles(src);
[fileListInTrg,~] = getAllFiles(trg);
 Vext=[".m" ".mat" ".mp4"];
 fileListInSrc=string(fileListInSrc);
 fileListInTrg=string(fileListInTrg); 
if ~isempty(fileListInTrg)   %%trg has files in it
        %%compare file names and copy over
    %%check file ext, copy only those with Vext
    for i=1:length(fileListInSrc)
        [filepath,name,ext] = fileparts(fileListInSrc(i));
        if ismember(ext,Vext)
            if ~ismember(name,fileListInTrg)
                if ~strcmp(filepath,src)
                %%copy
                newFolder = replace(filepath,src,trg);
                mkdir (newFolder)
                copyfile(fileListInSrc(i),newFolder)
                else
                copyfile(fileListInSrc(i),trg)
                end
            else 
            end
        end
        
    end
else %% trg is empty 
    %%copy everything over
     for i=1:length(fileListInSrc)
        [filepath,~,ext] = fileparts(fileListInSrc(i));
        if ismember(ext,Vext)
                if ~strcmp(filepath,src)
                %%copy
                newFolder = replace(filepath,src,trg);
                mkdir (newFolder)
                copyfile(fileListInSrc(i),newFolder)
                else
                copyfile(fileListInSrc(i),trg)
                end
        end
        
    end
end 
end