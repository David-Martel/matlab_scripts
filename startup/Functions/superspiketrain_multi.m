function sst_multi = superspiketrain_multi(tank_list,block_list,channel,unit)
    
% tank_list is a cell. Ex: {'F:\CW65' 'F:\CW65B' 'F:\CW65C'}
% block_list is a matrix. Ex: [15 16 17 1 2 3 1 2; 1 1 1 2 2 2 3 3]
% first row of block_list is actual block number, second row is the index
% of which tank it belongs to from the tank_list. Index number must not
% exceed number of tanks
%
% Calvin Wu, 5-9-2016

sst_list=cell(1,length(tank_list));
for t_count=1:length(tank_list)
    T=tank_list{t_count};
    B_perTank=find(block_list(2,:)==t_count);
    B=block_list(1,B_perTank);
	sst_list{t_count}=superspiketrain(T,B,channel,unit);
end

sst_list_new=sst_list{1};
for i=1:length(sst_list)-1
    sst_list_new=concat_sst(sst_list_new,sst_list{i+1});
end
sst_multi=sst_list_new;
% sst_multi.Tank=cellstr(strsplit(sst_multi.Tank));
sst_multi.Block=block_list;
sst_multi=fix_NTrials(sst_multi);

end


function sstc = concat_sst(sst1,sst2)

sstc=sst1;
sstc.Tank=[char(sst1.Tank) ' ' char(sst2.Tank)];
sstc.Block=[reshape(sstc.Block,1,numel(sstc.Block)) reshape(sst2.Block,1,numel(sst2.Block))];
sstc.BlockNames=[sstc.BlockNames sst2.BlockNames];

sstc.Channel=unique([sst1.Channel sst2.Channel]);
sstc.Unit=unique([sst1.Unit sst2.Unit]);
sstc.NTrials=sum([sst1.NTrials sst2.NTrials]);

% correct inconsistent epoc names
if ~isequal(sst1.EpocNames,sst2.EpocNames)
    warning('Epocs are inconsistent, use NaN');
    comp_a=ismember(sst1.EpocNames,sst2.EpocNames);
    comp_b=ismember(sst2.EpocNames,sst1.EpocNames);
    if length(comp_a)>length(comp_b)
        add_data=mat2dataset(NaN(length(sst2.Epocs.Values),sum(~comp_a)),'varnames',sst1.EpocNames(~comp_a));
        sst2.Epocs.Values=[sst2.Epocs.Values add_data];
        add_data=mat2dataset(repmat(sst2.Epocs.TSOn.swep,1,sum(~comp_a)),'varnames',sst1.EpocNames(~comp_a));
        sst2.Epocs.TSOn=[sst2.Epocs.TSOn add_data];
        add_data=mat2dataset(repmat(sst2.Epocs.TSOff.swep,1,sum(~comp_a)),'varnames',sst1.EpocNames(~comp_a));
        sst2.Epocs.TSOff=[sst2.Epocs.TSOff add_data];
    else
        add_data=mat2dataset(NaN(length(sst1.Epocs.Values),sum(~comp_b)),'varnames',sst2.EpocNames(~comp_b));
        sst1.Epocs.Values=[sst1.Epocs.Values add_data];
        add_data=mat2dataset(repmat(sst1.Epocs.TSOn.swep,1,sum(~comp_b)),'varnames',sst2.EpocNames(~comp_b));
        sst1.Epocs.TSOn=[sst1.Epocs.TSOn add_data];
        add_data=mat2dataset(repmat(sst1.Epocs.TSOff.swep,1,sum(~comp_b)),'varnames',sst2.EpocNames(~comp_b));
        sst1.Epocs.TSOff=[sst1.Epocs.TSOff add_data];
    end
end

% cat Epocs
if ~ismember(sstc.Epocs.Values.Properties.VarNames,'tind')
    sstc.Epocs.Values=[mat2dataset(ones(sst1.NTrials,1),'varnames','tind'),sst1.Epocs.Values;...
        mat2dataset(ones(sst2.NTrials,1)*2,'varnames','tind'),sst2.Epocs.Values];
    sstc.Epocs.TSOn=[mat2dataset(ones(sst1.NTrials,1),'varnames','tind'),sst1.Epocs.TSOn;...
        mat2dataset(ones(sst2.NTrials,1)*2,'varnames','tind'),sst2.Epocs.TSOn];
    sstc.Epocs.TSOff=[mat2dataset(ones(sst1.NTrials,1),'varnames','tind'),sst1.Epocs.TSOff;...
        mat2dataset(ones(sst2.NTrials,1)*2,'varnames','tind'),sst2.Epocs.TSOff];
    sstc.EpocNames=['tind';unique([sst1.EpocNames;sst2.EpocNames])];
else
    ex_ind=max(sstc.Epocs.Values.tind);
    sst2.Epocs.Values.tind=ones(sst2.NTrials,1)+ex_ind;
	sst2.Epocs.TSOn.tind=ones(sst2.NTrials,1)+ex_ind;
    sst2.Epocs.TSOff.tind=ones(sst2.NTrials,1)+ex_ind;
    sstc.Epocs.Values=[sstc.Epocs.Values;sst2.Epocs.Values];
    sstc.Epocs.TSOn=[sstc.Epocs.TSOn;sst2.Epocs.TSOn];
    sstc.Epocs.TSOff=[sstc.Epocs.TSOff;sst2.Epocs.TSOff];
    sstc.EpocNames=unique([sstc.EpocNames;sst2.EpocNames]);
end

% correct inconsistent spikes mat varnames
test=unique(cat(2,sstc.Spikes.Properties.VarNames,sst2.Spikes.Properties.VarNames));
for i=1:length(test)
    if ~ismember(test{i},sstc.Spikes.Properties.VarNames)
        sstc.Spikes=[sstc.Spikes,mat2dataset(NaN(size(sstc.Spikes,1),1),'varnames',test{i})];
    end
    if ~ismember(test{i},sst2.Spikes.Properties.VarNames)
        sst2.Spikes=[sst2.Spikes,mat2dataset(NaN(size(sst2.Spikes,1),1),'varnames',test{i})];
    end
end

% cat Spikes
if ~ismember(sstc.Spikes.Properties.VarNames,'TankIdx')
    sstc.Spikes=[sstc.Spikes,mat2dataset(ones(length(sstc.Spikes.TS),1),'varnames','TankIdx');...
        sst2.Spikes,mat2dataset(ones(length(sst2.Spikes.TS),1)*2,'varnames','TankIdx')];
else
    ex_ind=max(sstc.Spikes.TankIdx);
    sst2.Spikes.TankIdx=ones(length(sst2.Spikes.TS),1)+ex_ind;
    sstc.Spikes=[sstc.Spikes;sst2.Spikes];
end



end