% function RF = get_RF(sst)
    
    sst = sst_sorted{1,1};
    
    % find the RF trials
    blocks = unique(sst.Epocs.Values.Block);
    
    for i = 1:length(blocks)
       % find how many block indices
       f_inds = unique(sst.Epocs.Values.find(sst.Epocs.Values.Block == blocks(i)));
       % check to see if the block index is a RF
       for j = 1:length(f_inds)
          freqs = unique(sst.Epocs.Values.frq1(sst.Epocs.Values.Block == blocks(i) ...
              & sst.Epocs.Values.find == f_inds(j)));
          levs = unique(sst.Epocs.Values.lev1(sst.Epocs.Values.Block == blocks(i) ...
              & sst.Epocs.Values.find == f_inds(j)));
          if length(freqs) > 10
              rf_freqs = freqs;
              rf_levs = levs;
              rf_block = blocks(i);
              rf_find = f_inds(j);
          end
       end
    end
    
    rf_trials = sst.Epocs.Values.swep(sst.Epocs.Values.Block == rf_block & sst.Epocs.Values.find == rf_find);
    RF_mat = [];
    for i = 1:length(rf_freqs)
        for j = 1:length(rf_levs)
            trial_nums = sst.Epocs.Values.swep(sst.Epocs.Values.Block == rf_block & ...
                sst.Epocs.Values.find == rf_find & sst.Epocs.Values.frq1 == rf_freqs(i) & ...
                sst.Epocs.Values.lev1 == rf_levs(j));
            
            spikes = sst.Spikes(ismember(sst.Spikes.TrialIdx, trial_nums),:);
            trial_duration = sst.Epocs.TSOff.swep(trial_nums(1)) - sst.Epocs.TSOn.swep(trial_nums(1)); 
            
            RF_mat(j,i) = length(spikes)/(length(trial_nums)*trial_duration);
        end
    end

% end