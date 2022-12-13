function [wf_data,tdt] = tank_STRM(tankpath,block,t_after_on,varargin)
% getting ABR/CAP data from tank; example:
% t_after_on = 0.01;
% tankpath = 'F:\CW77B';
% block = 'Block-7';
% varargin{1}: select channel, default: channel 6

default_ch = 6;
if ~isempty(varargin)
   default_ch = varargin{1};
end

tdt=TDT2mat(tankpath,block,'CHANNEL',default_ch,'type',[2 4]);

strm=tdt.streams.STRM.data;
% plot(linspace(0,length(strm)/data.streams.STRM.fs,length(strm)),strm)
strmTime=linspace(1./tdt.streams.STRM.fs,length(strm)/tdt.streams.STRM.fs,length(strm));
wf_data=struct();
wf_data.epocs=tdt.epocs;
numSam=floor(t_after_on*tdt.streams.STRM.fs);
levTimeOn=tdt.epocs.Lev1.onset;

for i=1:length(levTimeOn)
    idx=find(strmTime>=levTimeOn(i));
    wf_data.waveform(i,:)=strm(idx(1):idx(1)+numSam-1);
    disp_progress(i,length(levTimeOn));
end


end