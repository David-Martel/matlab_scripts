function unit_sp = load_unit_sp(exp_name,varargin)
% exp_name='CW65a';
% varargin: load sst, true/false

default_path = '\\maize.umhsnas.med.umich.edu\khri-ses-lab\Calvin\Analysis\sst_mat';
fn = fullfile(default_path,[exp_name '_index']);
fn_sst = fullfile(default_path,exp_name);
ll = load(fn);

if isempty(varargin)
   to_load = true; 
else
   to_load = logical(varargin{1}); 
end

if ~ismember('sst',ll.unit_sp.Properties.VarNames)&&to_load
    sst=cell(length(ll.unit_sp),1);
    for u=1:length(ll.unit_sp)
        fprintf('loading unit %d-%d (%d/%d)\n',...
            ll.unit_sp.ch(u),ll.unit_sp.unit(u),u,length(ll.unit_sp));
        try 
            sst{u}=get_sorted_sst(fn_sst,ll.unit_sp.ch(u),ll.unit_sp.unit(u));
        end
    end
    unit_sp=[ll.unit_sp,table2dataset(table(sst))];
else
    unit_sp = ll.unit_sp;
end



end