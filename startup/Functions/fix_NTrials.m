function sst_out = fix_NTrials(sst_in)

sst_out = sst_in;
if sst_in.NTrials~=length(sst_in.Epocs.Values)
    sst_out.NTrials=length(sst_in.Epocs.Values);
end

end