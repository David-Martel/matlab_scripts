function y = rms_derp(u)
    y = sqrt(sum(u.*conj(u))/max(size(u)));
end