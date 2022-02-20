function [ear_assigns,pt_array] = get_ear_pts(gr_pts,frame_size,num_frames,num_pts,varargin)

med_filter_size = [5 5 3];
left_bound = 180;
right_bound = 520;
num_ears = 2;
point_thresh = 0.0005;

gr_pts = reshape(gr_pts,frame_size(1),frame_size(2),num_frames);

gr_pts(:,1:left_bound,:) = false;
gr_pts(:,right_bound:end,:) = false;

if sum(gr_pts(:))/num_pts >= point_thresh
    
    if ~isempty(varargin)
        gr_pts = gpu_medfilt3(gr_pts,med_filter_size);
        pt_array = green2ptidx(gr_pts);
        ear_assigns = dtm_kmedians(pt_array,num_ears);
    else
        gr_pts = medfilt3(gr_pts,med_filter_size);
        pt_array = green2ptidx(gr_pts);
        ear_assigns = kmedoids(pt_array,num_ears);   
    end
        
else
    
    ear_assigns = [];
    pt_array = [];
    
end


