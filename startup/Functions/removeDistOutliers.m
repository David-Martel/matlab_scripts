function [out_pixels,out_iter] = removeDistOutliers(pixel_vals,radius,max_iter)

if isempty(pixel_vals)
    out_pixels = nan(1,2);
    out_iter = -1;
else
    
    out_iter = max_iter;
    if max_iter == 0
        out_pixels = pixel_vals;
        
    else
        
        [num_pixel_orig,num_dim] = size(pixel_vals);
        
        mean_pixel = mean(pixel_vals);
        mean_pixel_loc = sum(mean_pixel.^2);
        
        pixel_dist_mean = (pixel_vals-mean_pixel);
        dist = sum(pixel_dist_mean.^2,2);
        
        thresh_idx = dist<(radius)^2;
        out_pixels = pixel_vals(thresh_idx,:);
        
        addpixel = max([100 ceil(num_pixel_orig*0.2)]); 
        new_pixel = round(mean(out_pixels)+randn(addpixel,num_dim,class(out_pixels)));
        out_pixels = unique([out_pixels; new_pixel],'rows');
            
        
        new_mean_pixel = mean(out_pixels);
        new_mean_pixel_loc = sum(new_mean_pixel.^2);
        
        percent_change = abs((mean_pixel_loc-new_mean_pixel_loc)/mean_pixel_loc)*100;
        
        if percent_change > 0.1
            [out_pixels,out_iter] = removeDistOutliers(out_pixels,radius,max_iter-1);
        end
        
    end
    
end
% figure(5)
% clf(5)
% hold on
%
% scatter(pixel_dist_mean(:,1),pixel_dist_mean(:,2),'ko')
%
% xlim([-30 30])
% ylim([-30 30])

