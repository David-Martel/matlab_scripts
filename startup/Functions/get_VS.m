function [R_VS,Ph,sig,X,Y] = get_VS(ts,tone_dur,F_m)

% ts: spike timestamp (0 = onset)
% tone_dur: tone duration
% F_m: known modulation frequency
% varargout would be X and Y for plotting when fig is true
% 
%
%

period=1/F_m;
nCycle=tone_dur./period; 

ts_cycle=[];
for p=1:ceil(nCycle)
    ts_p = ts(ts>(period*(p-1))&ts<=(period*p));
    ts_cycle=[ts_cycle; ts_p - period*(p-1)];
end

% period histogram
    X=0:period*0.05:period;
    Y=transpose(histc(ts_cycle,X));
    

% VS calculation
ts_rad_phase = ts_cycle./period*2*pi;

R_VS = sqrt(sum(cos(ts_rad_phase))^2 + sum(sin(ts_rad_phase))^2)./length(ts_rad_phase);
RS = 2*(R_VS^2)*length(ts_rad_phase);
Ph = atan2(sum(sin(ts_rad_phase)),sum(cos(ts_rad_phase)));

sig = RS>13.8;

% VS calculation using complex number
% ph_complex = exp(i*ts_rad_phase);
% R_VS = abs(sum(ph_complex))./length(ts_rad_phase);
% Ph = angle(sum(ph_complex));




end



