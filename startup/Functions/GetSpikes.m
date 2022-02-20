        %Returns the timestamps associated with the requested list of
        %trials
        function [Spikes] = GetSpikes(obj,trials,rastertype)
        % [Spikes]=GetSpikes(obj,trials,rastertype) returns the time stamps
        % for the requested set of trials and raster. 
        % 
        % Use of TrialSelect is highly encouraged for generation of a list 
        % of trials according to stimulus parameters used in experiments.
        
        
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

 
        Spikes=obj.Spikes.(['Raster' rastertype])(ismember(obj.Spikes.TrialIdx,trials));
           
           
        end