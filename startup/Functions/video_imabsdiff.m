function motion_trace = video_imabsdiff(video_data)

mean_image = uint8(mean(video_data,4));

motion_vid = video_data-mean_image;

motion_trace = mean(motion_vid,[1 2 3]);
motion_trace = motion_trace(:);














