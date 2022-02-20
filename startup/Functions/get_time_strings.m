function [date_str,time_str] = get_time_strings()

cur_time = datestr(now,'mmm-dd-yyyy_HH-MM-SS');
cur_time_parts = strsplit(cur_time,'_');

date_str = sprintf('_date-%s',cur_time_parts{1});
time_str = sprintf('_time-%s',cur_time_parts{2});







