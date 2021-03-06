%opticalFlowFarneback Estimate optical flow using Farneback algorithm.
%   obj = opticalFlowFarneback returns an optical flow object, obj, that
%   estimates the direction and speed of object motion from previous video
%   frame to the current one using Gunnar Farneback algorithm.
%
%   obj = opticalFlowFarneback(Name, Value) specifies additional name-value
%   pairs described below:
%
%   'NumPyramidLevels' Number of pyramid layers including the initial image. 
%                      Value of 1 means that no extra layers are created
%                      and only the original images are used.
%
%                      Default: 3
%
%   'PyramidScale'     Image scale to build pyramids for each image in each 
%                      level. It's a scalar between 0 and 1. Value of 0.5
%                      creates a classical pyramid, where each next layer
%                      is twice smaller than the previous one.
%
%                      Default: 0.5
%
%   'NumIterations'    Number of iterations spent computing at each pyramid
%                      level.
%
%                      Default: 3
%
%   'NeighborhoodSize' Size of the pixel neighborhood. Larger values yield 
%                      more robust and more blurred motion field. Typical
%                      value is 5 or 7.
%
%                      Default: 5
%
%   'FilterSize'       Averaging filter size. A Gaussian filter of size
%                      FilterSize x FilterSize is used to smooth out the
%                      neighboring displacements. Larger values are used
%                      for fast motion detection.
%
%                      Default: 15
%
%   opticalFlowFarneback properties:
%      NumPyramidLevels   - Number of pyramid layers including the initial image
%      PyramidScale       - Image scale to build pyramids for each image
%      NumIterations      - Number of iterations
%      NeighborhoodSize   - Size of the pixel neighborhood
%      FilterSize         - Averaging filter size
%
%   opticalFlowFarneback methods:
%      estimateFlow - Estimates the optical flow
%      reset        - Resets the internal state of the object
%
%   Example: Compute and display optical flow  
%   ------------------------------------------
%     vidReader = VideoReader('visiontraffic.avi', 'CurrentTime', 11);
%     opticFlow = opticalFlowFarneback;
%     while hasFrame(vidReader)
%       frameRGB = readFrame(vidReader);
%       frameGray = rgb2gray(frameRGB);
%       % Compute optical flow
%       flow = estimateFlow(opticFlow, frameGray); 
%       % Display video frame with flow vectors
%       imshow(frameRGB) 
%       hold on
%       plot(flow, 'DecimationFactor', [5 5], 'ScaleFactor', 2)
%       drawnow
%       hold off 
%     end
%
%   See also opticalFlowHS, opticalFlowLK, opticalFlowLKDoG, opticalFlow, 
%            opticalFlow>plot.

%   Copyright 2015 MathWorks, Inc.
%
% References: 
%    Gunnar Farneback. "Two-Frame Motion Estimation Based on Polynomial 
%    Expansion". Proceedings of the 13th Scandinavian Conference on Image 
%    Analysis, Gothenburg, Sweden 2003

classdef opticalFlowFarneback_custom < handle & vision.internal.EnforceScalarHandle
%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>
%#ok<*MCSUP>
  
  %------------------------------------------------------------------------
  % Public properties which can only be set in the constructor
  %------------------------------------------------------------------------
  properties(SetAccess=public)
    %NumPyramidLevels Number of pyramid layers including the initial image
    NumPyramidLevels = int32(3);
    %PyramidScale Image scale to build pyramids for each image
    PyramidScale     = 0.5;
    %NumIterations Number of iterations
    NumIterations    = int32(3);
    %NeighborhoodSize Size of the pixel neighborhood
    NeighborhoodSize = int32(5);
    %FilterSize Averaging filter size
    FilterSize       = int32(15);
    
  end
  
  %------------------------------------------------------------------------
  % Hidden properties used by the object
  %------------------------------------------------------------------------
  properties(Hidden, Access=private)
    pInRows = 0;
    pInCols = 0;
    
    pFirstCall;
    pPreviousFrameBuffer;
    params;
  end
  
  methods

    %----------------------------------------------------------------------
    % Constructor
    %----------------------------------------------------------------------
    function obj = opticalFlowFarneback_custom(varargin)
        
      % Parse the inputs.
      if isSimMode()
       [tmpPyramidScale, tmpNumPyramidLevels, tmpFilterSize, ...
           tmpNumIterations, tmpNeighborhoodSize] ...
        = parseInputsSimulation(obj, varargin{:});
      else % Code generation
        [tmpPyramidScale, tmpNumPyramidLevels, tmpFilterSize, ...
           tmpNumIterations, tmpNeighborhoodSize] ...
        = parseInputsCodegen(obj, varargin{:});
      end

      checkPyramidScale(tmpPyramidScale);
      checkNumPyramidLevels(tmpNumPyramidLevels);
      checkFilterSize(tmpFilterSize);
      checkNumIterations(tmpNumIterations);
      checkNeighborhoodSize(tmpNeighborhoodSize);
      
      obj.PyramidScale     = double(tmpPyramidScale);
      obj.NumPyramidLevels = int32(tmpNumPyramidLevels);
      obj.FilterSize       = int32(tmpFilterSize);
      obj.NumIterations    = int32(tmpNumIterations);
      obj.NeighborhoodSize = int32(tmpNeighborhoodSize);

      obj.pFirstCall = true;
      
      obj.params.pyr_scale  = double(obj.PyramidScale);
      obj.params.levels     = int32(obj.NumPyramidLevels);
      obj.params.winsize    = int32(obj.FilterSize);
      obj.params.iterations = int32(obj.NumIterations);
      obj.params.poly_n     = int32(obj.NeighborhoodSize);
      obj.params.poly_sigma = double(obj.NeighborhoodSize)*0.3;
      obj.params.flags      = int32(computeOCVflags());
      
    end
    
    %----------------------------------------------------------------------
    % Predict method
    %----------------------------------------------------------------------
    function [outVelReal,outVelImag] = estimateFlow(obj, ImageCurr) %, varargin)
        % estimateFlow Estimates the optical flow
        %   flow = estimateFlow(obj, I) estimates the optical flow between 
        %   the current frame I and the previous frame. 
        %    
        %   Notes
        %   -----
        %   - output flow is an object of class <a href="matlab:help('opticalFlow')">opticalFlow</a> that stores
        %     velocity matrices.
        %   - Class of input, I, can be double, single, uint8, int16, or logical.
        %   - For the very first frame, the previous frame is set to black.
        
%         checkImage(ImageCurr);
        if (~isSimMode())
            % compile time error if ImageCurr is not fixed sized
            eml_invariant(eml_is_const(size(ImageCurr)), ...
                eml_message('vision:OpticalFlow:imageVarSize'));
        end
        
        if ~(obj.pFirstCall)
            inRows_ = size(ImageCurr,1);
            inCols_ = size(ImageCurr,2);
            condition = (obj.pInRows ~= inRows_) || (obj.pInCols ~= inCols_);
            coder.internal.errorIf(condition, 'vision:OpticalFlow:inputSizeChange');
        end
        obj.pInRows = coder.const(size(ImageCurr,1));
        obj.pInCols = coder.const(size(ImageCurr,2));
        
        otherDT = coder.const('single');
        if isa(ImageCurr, 'uint8')
            tmpImageCurr = ImageCurr;
        else
            tmpImageCurr = im2uint8(ImageCurr);
        end
        
        if((obj.pInRows==0) || (obj.pInCols==0))
            velComponent = zeros(size(tmpImageCurr), otherDT);
            outVelReal = velComponent;
            outVelImag = velComponent;
            
            %outFlow = opticalFlow(velComponent, velComponent);
            return;
        end
        
        if (obj.pFirstCall)
            bufferSize = size(tmpImageCurr);
            if ~isSimMode() && coder.isColumnMajor
                bufferSize = flip(bufferSize);
            end
            obj.pPreviousFrameBuffer = zeros(bufferSize, 'like', tmpImageCurr);
            obj.pFirstCall = false;
        else
            coder.assertDefined(obj.pPreviousFrameBuffer);              
        end
        %ImagePrev = obj.pPreviousFrameBuffer;

        %inFlowXY = single([]);
        if isSimMode()
            % mex function: input images uint8, input initial flow: single
            %               output flow: (1) single and (2) concatenated
            % Output of matlab function:
            % (1) if input images double, output flow is double
            %     else output flow is single
            % (2) There are two outputs (X component, y component)
            
            outFlowXY = cast(ocvCalcOpticalFlowFarneback( ...
                obj.pPreviousFrameBuffer, tmpImageCurr, single([]), obj.params),...
                otherDT);
            
            % assign output flow
            outVelReal = outFlowXY(:,1:obj.pInCols);
            outVelImag = outFlowXY(:,(1:obj.pInCols)+obj.pInCols);        
            %outFlow = opticalFlow(outVelReal, outVelImag);
             obj.pPreviousFrameBuffer = tmpImageCurr;
        else
            if coder.isColumnMajor
                tmpImageCurrT = tmpImageCurr';
            else
                tmpImageCurrT = tmpImageCurr;
            end
            
            outFlowXY = cast(vision.internal.buildable.opticalFlowFarnebackBuildable.opticalFlowFarneback_compute( ...
                obj.pPreviousFrameBuffer, tmpImageCurrT, single([]), obj.params),...
                otherDT);
            
            % assign output flow
            outVelImag = outFlowXY(:,1:obj.pInCols);
            outVelReal = outFlowXY(:,(1:obj.pInCols)+obj.pInCols);   
            %outFlow = opticalFlow(outVelReal, outVelImag);
                    % prepare for next frame
            obj.pPreviousFrameBuffer = tmpImageCurrT;

        end

        
    end
    
    %-------------------------------------------------------------------
     function [outVelX,outVelY] = estimateFlow_video(obj, VideoData) %, varargin)
        % estimateFlow Estimates the optical flow
        %   flow = estimateFlow(obj, I) estimates the optical flow between 
        %   the current frame I and the previous frame. 
        %    
        %   Notes
        %   -----
        %   - output flow is an object of class <a href="matlab:help('opticalFlow')">opticalFlow</a> that stores
        %     velocity matrices.
        %   - Class of input, I, can be double, single, uint8, int16, or logical.
        %   - For the very first frame, the previous frame is set to black.
        
%         checkImage(ImageCurr);
%         if (~isSimMode())
%             % compile time error if ImageCurr is not fixed sized
%             eml_invariant(eml_is_const(size(VideoData)), ...
%                 eml_message('vision:OpticalFlow:imageVarSize'));
%         end
        
%         if ~(obj.pFirstCall)
%             inRows_ = size(VideoData,1);
%             inCols_ = size(VideoData,2);
%             condition = (obj.pInRows ~= inRows_) || (obj.pInCols ~= inCols_);
%             coder.internal.errorIf(condition, 'vision:OpticalFlow:inputSizeChange');
%         end
        obj.pInRows = coder.const(size(VideoData,1));
        obj.pInCols = coder.const(size(VideoData,2));
        
        otherDT = coder.const('single');
        
        vid_size = size(VideoData);
        num_dim = numel(vid_size);
        if num_dim==4 && vid_size(3)==1
            VideoData = squeeze(VideoData);
        end
        
        num_frames = coder.const(vid_size(numel(vid_size)));
        
        outVelX = zeros([obj.pInRows obj.pInCols num_frames],coder.const('single'));
        outVelY = zeros([obj.pInRows obj.pInCols num_frames],coder.const('single'));
        
%         VideoData = im2uint8(pagemtimes(VideoData,'transpose',...
%             repmat(eye(obj.pInRows,'single'),1,1,num_frames),'none'));

    
%         mh = mexhost;
%     
        for frame_iter = 1:(num_frames-1)
            
%             outFlowXY = cast(feval(mh,"ocvCalcOpticalFlowFarneback",...
%                 VideoData(:,:,frame_iter),VideoData(:,:,frame_iter+1),...
%                 single([]),obj.params),otherDT);

            outFlowXY = cast(ocvCalcOpticalFlowFarneback( ...
                VideoData(:,:,frame_iter), VideoData(:,:,frame_iter+1), single([]), obj.params),...
                otherDT);
            
%             outFlowXY = cast(vision.internal.buildable.opticalFlowFarnebackBuildable.opticalFlowFarneback_compute( ...
%                 VideoData(:,:,frame_iter)', VideoData(:,:,frame_iter+1)', single([]), obj.params),...
%                 otherDT);

            % assign output flow
            outVelX(:,:,frame_iter) = outFlowXY(:,1:obj.pInCols);
            outVelY(:,:,frame_iter) =  outFlowXY(:,(1:obj.pInCols)+obj.pInCols);     
        end    
        
    end
    
    %------------------------------------------------------------------
    function params = getParams(obj)
        params = obj.params;
    end
    
    %------------------------------------------------------------------
    function set.NumPyramidLevels(this, numPyramidLevels)
        checkNumPyramidLevels(numPyramidLevels);
        this.NumPyramidLevels = int32(numPyramidLevels);
        this.params.levels = this.NumPyramidLevels;
    end
    %------------------------------------------------------------------
    function set.PyramidScale(this, pyramidScale)
        checkPyramidScale(pyramidScale);
        this.PyramidScale = double(pyramidScale);
        this.params.pyr_scale = this.PyramidScale;
    end
    %------------------------------------------------------------------
    function set.NumIterations(this, numIterations)
        checkNumIterations(numIterations);
        this.NumIterations = int32(numIterations);
        this.params.iterations = this.NumIterations;
    end
    %------------------------------------------------------------------
    function set.NeighborhoodSize(this, neighborhoodSize)
        checkNeighborhoodSize(neighborhoodSize);
        this.NeighborhoodSize = int32(neighborhoodSize);
        this.params.poly_n = this.NeighborhoodSize;
        this.params.poly_sigma = double(this.NeighborhoodSize)*0.3;
    end
    %------------------------------------------------------------------
    function set.FilterSize(this, filterSize)
        checkFilterSize(filterSize);
        this.FilterSize = int32(filterSize);
        this.params.winsize = this.FilterSize;
    end    
    %----------------------------------------------------------------------
    % Correct method
    %----------------------------------------------------------------------
    function reset(obj)
        % reset Reset the internal state of the object
        %
        %   reset(flow) resets the internal state of the object. It sets 
        %   the previous frame to black.
        
        obj.pFirstCall = true;
    end    
  end
  
  methods(Access=private)
    %----------------------------------------------------------------------
    % Parse inputs for simulation
    %----------------------------------------------------------------------
    function [tmpPyramidScale, tmpNumPyramidLevels, tmpFilterSize, ...
           tmpNumIterations, tmpNeighborhoodSize] ...
        = parseInputsSimulation(obj, varargin)
      
      % Instantiate an input parser
      parser = inputParser;
      parser.FunctionName = mfilename;
      
      % Specify the optional parameters
      parser.addParameter('PyramidScale',     obj.PyramidScale);
      parser.addParameter('NumPyramidLevels', obj.NumPyramidLevels);
      parser.addParameter('FilterSize',       obj.FilterSize);
      parser.addParameter('NumIterations',    obj.NumIterations);
      parser.addParameter('NeighborhoodSize', obj.NeighborhoodSize);
      
      % Parse parameters
      parse(parser, varargin{:});
      r = parser.Results;
      
      tmpPyramidScale     = r.PyramidScale;
      tmpNumPyramidLevels = r.NumPyramidLevels;
      tmpFilterSize       = r.FilterSize;           
      tmpNumIterations    = r.NumIterations;
      tmpNeighborhoodSize = r.NeighborhoodSize;

    end
    
    %----------------------------------------------------------------------
    % Parse inputs for code generation
    %----------------------------------------------------------------------
    function [tmpPyramidScale, tmpNumPyramidLevels, tmpFilterSize, ...
           tmpNumIterations, tmpNeighborhoodSize] ...
        = parseInputsCodegen(obj, varargin)

    % Check for string and error
    for n = 1 : numel(varargin)
        coder.internal.errorIf(isstring(varargin{n}), ...
            'vision:validation:stringnotSupportedforCodegen');
    end
    
      defaultsNoVal = struct( ...
        'PyramidScale',     uint32(0), ...
        'NumPyramidLevels', uint32(0), ...
        'FilterSize',       uint32(0), ...
        'NumIterations',    uint32(0), ...
        'NeighborhoodSize', uint32(0));
      
      properties = struct( ...
        'CaseSensitivity', false, ...
        'StructExpand',    true, ...
        'PartialMatching', false);
      
      optarg = eml_parse_parameter_inputs(defaultsNoVal, properties, varargin{:});
    
      tmpPyramidScale = eml_get_parameter_value(optarg.PyramidScale, ...
        obj.PyramidScale, varargin{:});
      tmpNumPyramidLevels = eml_get_parameter_value(optarg.NumPyramidLevels, ...
        obj.NumPyramidLevels, varargin{:});
      tmpFilterSize = eml_get_parameter_value(optarg.FilterSize, ...
        obj.FilterSize, varargin{:});    
      tmpNumIterations = eml_get_parameter_value(optarg.NumIterations, ...
        obj.NumIterations, varargin{:});   
      tmpNeighborhoodSize = eml_get_parameter_value(optarg.NeighborhoodSize, ...
        obj.NeighborhoodSize, varargin{:});   
    end
  end
end
               
%========================================================================== 
function flag = isSimMode()

flag = isempty(coder.target);
end

%==========================================================================
% function checkImage(I)
% % Validate input image
% 
% validateattributes(I,{'uint8', 'int16', 'double', 'single', 'logical'}, ...
%     {'real','nonsparse', '2d'}, mfilename, 'ImageCurr', 1)
% 
% end

%==========================================================================
function checkPyramidScale(PyramidScale)
 validateattributes(PyramidScale, {'numeric'}, {'nonempty', 'nonnan', ...
    'finite', 'nonsparse', 'real', 'scalar', '>', 0, '<', 1}, ...
    mfilename, 'PyramidScale');    
end

%==========================================================================
function checkNumPyramidLevels(NumPyramidLevels)
 validateattributes(NumPyramidLevels, {'numeric'}, ...
    {'nonempty', 'real', 'integer', 'nonnan', 'nonsparse', 'scalar', '>', 0}, ...
    mfilename, 'NumPyramidLevels');
end

%==========================================================================
function checkFilterSize(FilterSize)
% For FilterSize=1 output flow is really noisy. Disallowing FilterSize=1
 validateattributes(FilterSize, {'numeric'}, ...
    {'nonempty', 'real', 'integer', 'nonnan', 'nonsparse', 'scalar', '>', 1}, ...
    mfilename, 'FilterSize');
end

%==========================================================================
function checkNumIterations(NumIterations)
 validateattributes(NumIterations, {'numeric'}, ...
    {'nonempty', 'real', 'integer', 'nonnan', 'nonsparse', 'scalar', '>', 0}, ...
    mfilename, 'NumIterations');
end

%==========================================================================
function checkNeighborhoodSize(NeighborhoodSize)
 validateattributes(NeighborhoodSize, {'numeric'}, ...
    {'nonempty', 'real', 'integer', 'nonnan', 'nonsparse', 'scalar', '>', 0}, ...
    mfilename, 'NeighborhoodSize');
end

%==========================================================================
function  flags = computeOCVflags()

    % here (1) initial flow is not used
    %      (2) Gaussian filter is used
    flags = int32(256);
end

%==========================================================================
% function polySigma = computePolySigma(NeighborhoodSize)
%       
%  polySigma = double(NeighborhoodSize)*0.3;
% end
