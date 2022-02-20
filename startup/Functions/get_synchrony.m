function [pXCC,pTime,X,Y,sig_cutoff] = get_synchrony(spiketrain1,spiketrain2,interval)
%
%
%
%

%% remove common spikes w/in 150 us
sig_0=spiketrain1;
sig_1=spiketrain2;
too_close = pdist2(spiketrain1,spiketrain2,'cityblock') <= 0.00015;
sig_0_bad = sum(too_close,2) >= 1;
sig_1_bad = sum(too_close) >= 1;
sig_0(sig_0_bad) = [];
sig_1(sig_1_bad) = [];
spiketrain1=sig_0;
spiketrain2=sig_1;

%%
bins=0.1/1000;
lim=10/bins/1000;

time = 0:bins:interval;
N = length(time);
N_A = length(spiketrain1);
N_B = length(spiketrain2);
train1=hist(spiketrain1,time);
train2=hist(spiketrain2,time);

[R,time_lag] = xcorr(train1,train2);

E = N_A*N_B/N;
STD_CORR = sqrt(E);
R_ZSCORE = (R-E)/STD_CORR;
cutoff = 4;
sig_corr = R_ZSCORE >= cutoff|R_ZSCORE <= -cutoff;
lags = find(sig_corr == 1);
lags = lags+time_lag(1)-1;
corr_coef = (R-E)/sqrt(N_A*N_B);
sig_cutoff = cutoff/sqrt(N);

flag=find(lags<=lim&lags>=-lim);
if ~isempty(flag)
    inx = time_lag<=lim&time_lag>=-lim;
	X = time_lag(inx)*bins*1000;
    Y = corr_coef(inx);
    [~,im]=max(abs(Y));
    pXCC = Y(im);
    pTime = X(im);
else
    X=NaN;
    Y=NaN;
	pXCC=NaN;
    pTime=NaN;
end
% plot(X,Y);hold on;plot(pTime,pXCC,'o')


end