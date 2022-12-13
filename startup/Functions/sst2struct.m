function sstpy = sst2struct(sst)

sstpy=struct;
sstpy.spikes=dataset2struct(sst.Spikes);
sstpy.epocs.values=dataset2struct(sst.Epocs.Values);
sstpy.epocs.tson=dataset2struct(sst.Epocs.TSOn);
sstpy.epocs.tsoff=dataset2struct(sst.Epocs.TSOff);

end