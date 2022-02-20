function [tone, tVec, env] = genTone(amp, freq, dur, riseDur, phase, Fs)
% amp = amplitude, arb. (eg. Volts)
% freq = frequency, Hz
% dur = duration, S
% riseDur = rise/fall time, in S
% Fs = Sampling frequency, Hz

% Calculate number of points required
dt = 1/Fs;
% Length in pts
% npts (pts) = dur (S) * Fs (pts/S)
nPts = round(dur * Fs);

% Generate time vector
tVec = 0:dt:dur-dt;

% Generate tone
tone = amp * sin(pi*2*freq.*tVec + phase);

% Generate rise/fall
nPtsRise = round(riseDur * Fs);
tVecRise = -pi/2 : abs(-pi/2-0)/(nPtsRise-1) : 0;
% Equiv to linspace(-pi/2, 0, nPtsRise)

% Generate rise
rise = cos(tVecRise);
fall = rise(end:-1:1);

% Add to envelope
env = ones(1, nPts);
env(1:nPtsRise) = rise;
env(end-(nPtsRise-1):end) = fall;

% Apply envelope to tone
tone = env .* tone;