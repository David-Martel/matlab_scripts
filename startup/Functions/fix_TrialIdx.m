function obj = fix_TrialIdx(obj)


if ismember('tind',obj.Epocs.Values.Properties.VarNames) % sst_multi => fix, otherwise disregard
    if min(diff(obj.Spikes.TrialIdx))<0 % if already fixed, disregard
        [~,sep] = unique(obj.Spikes.TankIdx);
        sep=[sep;length(obj.Spikes.TankIdx)+1];
        for i=2:length(sep)-1
            tank_n = obj.Spikes.TankIdx(sep(i));
            trial_prev = max(find(obj.Epocs.Values.tind==(tank_n-1)));
            
            obj.Spikes.TrialIdx(sep(i):sep(i+1)-1) = obj.Spikes.TrialIdx(sep(i):sep(i+1)-1) + trial_prev;
        end
    end
end

end