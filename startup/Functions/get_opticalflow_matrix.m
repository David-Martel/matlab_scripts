function [block_data,motion_traces] = get_opticalflow_matrix(flow_data)%#codegen
% function [block_data,motion_traces] = get_opticalflow_matrix(vid_data,...
%     num_frame,resize_dim,thresh_val)
% gflow_data.vid_data = up_vid;
% gflow_data.num_frame = thresh_data.num_frame;
% gflow_data.resize_dim = thresh_data.frame_size;
% gflow_data.blocksize = thresh_data.block_size;
% gflow_data.block_thresh = thresh_data.block_thresh;

op_inputs = struct;
op_inputs.NeighborhoodSize = coder.const(int32(15)); %15
op_inputs.NumIterations = coder.const(int32(3));
op_inputs.NumPyramidLevels = coder.const(int32(2)); %3
op_inputs.PyramidScale = coder.const(0.5);
op_inputs.FilterSize = coder.const(int32(7)); %15

opticFlow = opticalFlowFarneback_custom(op_inputs);

flow_video = repmat({zeros([flow_data.resize_dim 2], 'single')},1,flow_data.num_frame);
frame_pixel = prod(flow_data.resize_dim);

flow_video(1) = opticFlow.estimateFlow(flow_data.vid_data(:,:,1));


for iter = 1:flow_data.num_frame
    
    flow_video(iter) = opticFlow.estimateFlow(flow_data.vid_data(:,:,iter));
    [block_score,block_score_idx] = max(im2col(...
        sqrt(sum((flow_video{iter}).*(flow_video{iter}),3)),flow_data.blocksize,'distinct')...
        ,[],'omitnan');
    
    [angle_blocks] = im2col(...
        atan2(flow_video{iter}(:,:,2),flow_video{iter}(:,:,1)),flow_data.blocksize,'distinct');
    
    block_angle = angle_blocks(block_score_idx);
    
    block_data.block_mag_store(iter,:) = block_score;
    block_data.block_ang_store(iter,:) = block_angle;
    
end
% release(opticFlow);

flow_matrix = cat(4,flow_video{:});
xvec = reshape(flow_matrix(:,:,1,:),frame_pixel,flow_data.num_frame);
yvec = reshape(flow_matrix(:,:,2,:),frame_pixel,flow_data.num_frame);

global_movex = reshape(mean(xvec,1,'native'),[],1);
global_movey = reshape(mean(yvec,1,'native'),[],1);

motion_traces.all_points = [global_movex global_movey];

%%
flow_mag = xvec.*xvec + yvec.*yvec;

bins = 500;
[cum_prob,thresh_value] = histcounts(reshape(flow_mag,[],1),...
    bins,'normalization','cdf');

frame_thresh = thresh_value(cum_prob*100>=flow_data.block_thresh);
drop_idx = flow_mag<=frame_thresh(1);

% drop_idx = flow_mag<prctile(reshape(flow_mag,[],1),thresh_val);
xvec(drop_idx) = nan;
yvec(drop_idx) = nan;

thresh_movex = reshape(mean(xvec,1,'native','omitnan'),[],1);
thresh_movey = reshape(mean(yvec,1,'native','omitnan'),[],1);

motion_traces.thresh_points = [thresh_movex thresh_movey];

end