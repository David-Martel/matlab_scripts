function superblock = load_sb(save_dir)

fid = fopen(fullfile(save_dir,'log.txt'),'a');

save_path = fullfile(save_dir,'superblock');
f_index = what(save_path);
f_list = f_index.mat;

for i=1:length(f_list)
    f_list{i,2} = load(fullfile(save_path,f_list{i,1}));
    if i==1
        tbl = f_list{i,2}.sb;
    else
        tbl = [tbl;f_list{i,2}.sb];
    end
    fprintf('%s\n',[num2str(i) '/' num2str(length(f_list))]);
    fprintf(fid,'%s: %s\r\n',datestr(now),[num2str(i) '/' num2str(length(f_list))]);
end

superblock={};
superblock{1} = tbl;

fclose(fid);

end