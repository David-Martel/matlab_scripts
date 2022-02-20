function [evoked_sync,mean_rate,peak_store,rate_store] = dtm_rf_sync(rf_spikes1,rf_spikes2)

lev_thresh = 40;
interval = 0.2;
    
%unit sanity check, RFs should be the same
levs1 = unique(rf_spikes1.lev);
frqs1 = unique(rf_spikes1.frq);

levs2 = unique(rf_spikes2.lev);
frqs2 = unique(rf_spikes2.frq);

if sum(levs1-levs2)~=0 || sum(frqs1-frqs2)~=0
    disp('Inconsistent RFs')
    evoked_sync = nan;
    mean_rate = nan;
    return
else
    
    frqs = frqs1;
    levs = levs1;
    
    peak_store = nan(length(levs),length(frqs));
    time_store = nan(length(levs),length(frqs));
    rate_store = nan(length(levs),length(frqs));
    
    for frq_iter = 1:length(frqs)
        
        frq_idx = rf_spikes1.frq == frqs(frq_iter);
        
        for lev_iter = 1:length(levs)
            
            lev_idx = rf_spikes1.lev == levs(lev_iter);
            
            ts_idx = frq_idx & lev_idx;
            ts1 = single(rf_spikes1.ts{ts_idx});
            ts2 = single(rf_spikes2.ts{ts_idx});
            
            [pXCC,pTime,~,~,~,gFR,~] = get_sync_dtm(ts1,ts2,interval,'removeCommon');
            
            peak_store(lev_iter,frq_iter) = pXCC;
            time_store(lev_iter,frq_iter) = pTime;
            rate_store(lev_iter,frq_iter) = gFR;
            
        end
    end
    
    %data_store(isnan(data_store)) = 0;
    
    
    peak_plot = movmean(peak_store,3,2,'omitnan');
    rate_plot = movmean(rate_store,3,2,'omitnan');
%     time_plot = movmean(abs(time_store),3,2,'omitnan');
%     
    data_keep = peak_plot(levs>=lev_thresh,:);
    evoked_sync = nanmean(data_keep(:));
    
    data_keep = rate_plot(levs>=lev_thresh,:);
    mean_rate = nanmean(data_keep(:));
end







