clear
clc
close

%Install FFMPEG first, make sure its available on the %PATH%
%https://windowsloop.com/install-ffmpeg-windows-10/

base_dir = pwd;
test_file = fullfile(base_dir,'derp_vid.mp4');
out_file = replace(test_file,'.mp4','_compress.mp4');

if exist(out_file,'file')
    delete(out_file);
end

crf_val = 18;
command_str = sprintf('ffmpeg -hwaccel auto -i "%s" -vcodec libx265 -preset fast -crf %d "%s"',test_file,crf_val,out_file);

% crf_val = 0;
% command_str = sprintf('ffmpeg -i "%s" -vcodec libx265 -x265-params lossless=1 "%s"',test_file,out_file);




[stat,result] = system(command_str);





