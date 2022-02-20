function sb_cell = build_sb(path, save_dir, rfs_user,varargin)

% path={'F:\CW65' 'F:\CW65B' 'F:\CW65C'}
% rfs_user=[15 16 1 2; 1 1 2 3]
% save_dir='F:\sorting' %main output directory
% varargin, put anything to disable remove electrial
%
% This code allow users to construct SUPERBLOCK (sb_cell: cell array with
% only one field), which is the first step for the auto sorting function.
% sb_cell output is fed into SORTER_C_SB sorting function in the next step.
%
% - CW
%
%
%

fid = fopen(fullfile(save_dir,'log.txt'),'a');

keep_artifact=false;
if ~isempty(varargin)
   keep_artifact=true;
end

% check input consistency
if (isstr(path)&size(rfs_user,1)~=1)|(iscell(path)&size(rfs_user,1)==1)
    error('check tank path and block list')
end
if size(rfs_user,1)==2&max(rfs_user(2,:))>length(cellstr(path))
    error('block index inconsistent')
end

save_dir=fullfile(save_dir,'superblock');
if ~exist(save_dir)
    mkdir(save_dir)
end

     
     if isstr(path)
         sb_out = build_rfblock_simple(path, rfs_user, keep_artifact,fid);
     elseif iscell(path)
         for i=1:length(path)
             path_str=path{i};
             block=rfs_user(1,rfs_user(2,:)==i);
             try
                sb = build_rfblock_simple(path_str, block,keep_artifact,fid);
             catch
                error([path_str ' does not exist']);
             end
             if i==1
                sb_out=[array2table(ones(height(sb),1)*i,'variablenames',{'tank'}) sb];
             else
                sb_out=[sb_out;array2table(ones(height(sb),1)*i,'variablenames',{'tank'}) sb];
             end
            fprintf('Tank-%d (of %d) compiled.\n',i,length(path));
            fprintf(fid,'%s: Tank-%d (of %d) compiled.\r\n',datestr(now),i,length(path));
         end
     else
         error('Invalid tank path format');
     end
     sb_cell={};
     sb_cell{1}=sb_out;
    save_separate_channels(save_dir,sb_out,fid);

    fclose(fid);
end


function save_separate_channels(save_dir, sb_out,fid)

fprintf('Saving...\n')
fprintf(fid,'%s: Saving...\r\n',datestr(now));

max_ch=max(sb_out.chan);
    for channel=1:max_ch
        sb = sb_out(sb_out.chan==channel,:);
        fname=fullfile(save_dir,['channel_' num2str(channel) '.mat']);
        save(fname,'sb','-v7.3')
    end
	fprintf('n = %d channels saved.\n',max_ch)
	fprintf(fid,'%s: n = %d channels saved.\r\n',datestr(now),max_ch);

end



function superblocks = build_rfblock_simple(path, rfs_user, keep_artifact,fid)

% see BUILD_RFBLOCK
% This code modified uneccessary considerations for identifying RFs and
% whatnot. This newer version only requests user for a list of blocks in
% array format and builds a superblock, regardless of which block has
% RF(s).
%
% - CW


for i_block=1:length(rfs_user)
    
    blockN=rfs_user(i_block);
    blockStr=['Block-' num2str(blockN)];

    try
        data=TDT2mat(path,blockStr,'Type',[2 3],'Verbose',0);
    catch
            error([path ' does not exist']);
        
    end
    if ~isempty(data.snips)
    block=ones(length(data.snips.CSPK.chan),1)*blockN;
    chan=data.snips.CSPK.chan;
    ts=data.snips.CSPK.ts;
    waves=double(data.snips.CSPK.data);
    sortc=zeros(length(data.snips.CSPK.chan),1);

    partList=unique(data.epocs.FInd.data);
    part=zeros(length(data.snips.CSPK.chan),1);
    for i_p=1:length(partList)
        idx=find(data.epocs.FInd.data==partList(i_p));
        t_start=data.epocs.FInd.onset(idx(1));
        t_end=data.epocs.FInd.offset(idx(end));
        ts_idx=find(data.snips.CSPK.ts>=t_start&data.snips.CSPK.ts<=t_end);
        part(ts_idx)=partList(i_p);
    end
    
    SB_com=table(block,chan,ts,sortc,waves,part);
    SB_com(SB_com.part==0,:)=[];
    
	epocs = data.epocs;
    if ~keep_artifact
        e_idx = remove_artifact(SB_com.ts,epocs,fid);
        SB_com(logical(e_idx),:)=[];
    end
    else
        SB_com=table([],[],[],[],[],[],'variablenames',...
            {'block','chan','ts','sortc','waves','part'});
    end
    fprintf('%s compiled. (%d/%d)\n',blockStr,i_block,length(rfs_user))
    fprintf(fid,'%s: %s compiled. (%d/%d)\r\n',datestr(now),blockStr,i_block,length(rfs_user));
    
    if i_block==1
        superblocks=SB_com;
    else
        superblocks=[superblocks;SB_com];
    end
end


end

function idx_tot = remove_artifact(ts,epocs,fid)

idx_tot = zeros(length(ts),1);
if ~isfield(epocs,'EAmp')|~isfield(epocs,'ETyp')
    return;
end

idx_e = find(epocs.EAmp.data~=0);
if isempty(idx_e)
    return;
end

for i=1:length(idx_e)
    e_on=epocs.ETyp.onset(idx_e(i));
    e_off=epocs.ETyp.offset(idx_e(i));
    idx_tot = idx_tot + double(ts>=e_on&ts<=e_off);
end

fprintf('Removed artifact.\n')
fprintf(fid,'%s: Removed artifact.\r\n',datestr(now));



end


