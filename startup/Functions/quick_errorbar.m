function [mean_vals,sem_vals] = quick_errorbar(x,dim)

mean_vals = mean(x,dim,'omitnan','double');
sem_vals = std(x,0,dim,'omitnan')./sqrt(sum(~isnan(x),dim,'omitnan','double'));







