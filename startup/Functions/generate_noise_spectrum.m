function [noise,freq,spectrum] = generate_noise_spectrum()


Fs = 48000;

noise = (rand(Fs,1)-0.5).*2;
noise = noise./max(abs(noise));

noise_fft = fft(noise);
freqs_eval = (0:1/length(noise):1-1/length(noise)).*Fs;

[Freq,Inten] = import_exposure_file(...
    ['U:\DavidM\Guinea Pig Ear Images\Noise_Exposure_Figure\noise shoreL short plastic tube 102_2 dB SPL.xls'],'SHL1022',1,400);

peak_val = find(Freq == 7000,1);
max_inten = Inten(peak_val);
peak_val = Freq(peak_val);

Inten(Freq <= peak_val - floor(peak_val/2)) = Inten(Freq == peak_val - floor(peak_val/2));
Inten(Freq >= peak_val + floor(peak_val/2)) = Inten(Freq == peak_val + floor(peak_val/2));

Inten(Freq > Fs/2) = [];
Freq(Freq > Fs/2) = [];

Inten = [Inten; Inten(end:-1:2)];
Inten = Inten-max(abs(Inten));
Freq = [Freq; Freq(2:end)+Freq(end)];

Inten_FFT = interp1(Freq,Inten,freqs_eval);
Inten_FFT = db2mag(Inten_FFT);

noise_fft = noise_fft.*Inten_FFT';

noise = real(ifft(noise_fft));

freq = freqs_eval;
spectrum = smooth(mag2db(abs(noise_fft)),25);
spectrum = spectrum - max(abs(spectrum)) + max_inten;

freq = freq(1:end/2);
spectrum = spectrum(1:end/2);

end
