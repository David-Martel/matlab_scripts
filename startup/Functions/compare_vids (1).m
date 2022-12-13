clear
clc
close all

imaqreset

vid1 = videoinput('winvideo', 1, 'MJPG_1920x1080');
src1 = getselectedsource(vid1);
vid1.FramesPerTrigger = 1;


vid2 = videoinput('winvideo', 2, 'MJPG_1920x1080');
src2 = getselectedsource(vid2);
vid2.FramesPerTrigger = 1;

vid_array = [vid1 vid2];

start(vid_array)

frame1 = getdata(vid1);
frame2 = getdata(vid2);

comp_frame = cat(2,frame1,frame2);
















