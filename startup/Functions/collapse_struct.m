function collapse_struct(S)

fnames=fieldnames(S)';
for i=1:length(fnames)
    assignin('base',fnames{i},S.(fnames{i}))
end

end