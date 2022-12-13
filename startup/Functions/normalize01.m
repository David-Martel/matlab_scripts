function yout=normalize01(yin)
    yout=(yin-min(yin))./(max(yin)-min(yin));
end