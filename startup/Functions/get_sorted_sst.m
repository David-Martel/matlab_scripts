function sst = get_sorted_sst(exp_dir,varargin)
%
%
% eg:
% exp_dir = 'F:\sorting\CW66a1';
% ch=1;
% unit=3;
% example sst = get_sorted_sst(exp_dir,ch,unit)

warning('on');

if isempty(varargin)
    ch=[];
    unit=[];
    sst={};
    f_dir=what(exp_dir);
    for i=1:length(f_dir.mat)
        str=f_dir.mat{i};
        p1=9;
        p2=strfind(str,'.mat')-1;
        a=load(fullfile(exp_dir,str));
        ch=[ch;ones(length(a.sst_sorted),1)*str2num(str(p1:p2))];
        unit=[unit;transpose((1:length(a.sst_sorted))-1) ];
        sst=[sst;a.sst_sorted];
    end
    sst=table(ch,unit,sst);
    sst=sortrows(sst,'ch');
    sst=table2dataset(sst);
elseif ~isempty(varargin)&nargin==3
    w=0;
    ch=varargin{1};
    unit=varargin{2};
    chstr=['channel_' num2str(ch) '.mat'];
    fpath=fullfile(exp_dir,chstr);
    try
        sst_file=load(fpath);
    catch
        warning('Path does not exist.');
        w=1;
    end
    
    if w==0
        if length(sst_file.sst_sorted) >= (unit+1)
            sst=sst_file.sst_sorted(unit+1);
        else
            warning('Unit does not exist.');
            w=1;
        end
    end
    
    if w==1
        sst=NaN;
    end
end



end