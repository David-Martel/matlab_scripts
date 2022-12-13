function m = compute_monotonicity(rlf_data)

end_val = find(~isnan(rlf_data),1,'last');
rate_max_level = rlf_data(end_val);

spont_val = find(~isnan(rlf_data),1,'first');
rate_spont = rlf_data(spont_val);

rate_max = nanmax(rlf_data);


m = (rate_max_level-rate_spont)/(rate_max - rate_spont);













