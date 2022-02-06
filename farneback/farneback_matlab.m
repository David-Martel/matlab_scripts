function farneback_matlab()

end

%-------------------------------------------------------------------
% class FarnebackOpticalFlowImpl : public FarnebackOpticalFlow
% {
% public:
%             FarnebackOpticalFlowImpl(int numLevels=5, double pyrScale=0.5, bool fastPyramids=false, int winSize=13,
%                     int numIters=10, int polyN=5, double polySigma=1.1, int flags=0) :
%             numLevels_(numLevels), pyrScale_(pyrScale), fastPyramids_(fastPyramids), winSize_(winSize),
%                     numIters_(numIters), polyN_(polyN), polySigma_(polySigma), flags_(flags)
%             {
%             }
%
%             virtual int getNumLevels() const CV_OVERRIDE { return numLevels_; }
%             virtual void setNumLevels(int numLevels) CV_OVERRIDE { numLevels_ = numLevels; }
%
%             virtual double getPyrScale() const CV_OVERRIDE { return pyrScale_; }
%             virtual void setPyrScale(double pyrScale) CV_OVERRIDE { pyrScale_ = pyrScale; }
%
%             virtual bool getFastPyramids() const CV_OVERRIDE { return fastPyramids_; }
%             virtual void setFastPyramids(bool fastPyramids) CV_OVERRIDE { fastPyramids_ = fastPyramids; }
%
%             virtual int getWinSize() const CV_OVERRIDE { return winSize_; }
%             virtual void setWinSize(int winSize) CV_OVERRIDE { winSize_ = winSize; }
%
%             virtual int getNumIters() const CV_OVERRIDE { return numIters_; }
%             virtual void setNumIters(int numIters) CV_OVERRIDE { numIters_ = numIters; }
%
%             virtual int getPolyN() const CV_OVERRIDE { return polyN_; }
%             virtual void setPolyN(int polyN) CV_OVERRIDE { polyN_ = polyN; }
%
%             virtual double getPolySigma() const CV_OVERRIDE { return polySigma_; }
%             virtual void setPolySigma(double polySigma) CV_OVERRIDE { polySigma_ = polySigma; }
%
%             virtual int getFlags() const CV_OVERRIDE { return flags_; }
%             virtual void setFlags(int flags) CV_OVERRIDE { flags_ = flags; }
%
%             virtual void calc(InputArray I0, InputArray I1, InputOutputArray flow) CV_OVERRIDE;
%
%             virtual String getDefaultName() const CV_OVERRIDE { return "DenseOpticalFlow.FarnebackOpticalFlow"; }
%
% private:
%             int numLevels_;
%             double pyrScale_;
%             bool fastPyramids_;
%             int winSize_;
%             int numIters_;
%             int polyN_;
%             double polySigma_;
%             int flags_;
% };


%%
function FarnebackPrepareGaussian(n, sigma, g, xg, xxg,...
    ig11, ig03, ig33, ig55)
% function	FarnebackPrepareGaussian(int n, double sigma, float *g, float *xg, float *xxg,...
%         double &ig11, double &ig03, double &ig33, double &ig55)

if( sigma < eps )
    sigma = n*0.3;
end

s = 0;
for x = -n:1:n
    g(x) = exp(-x*x/(2*sigma*sigma));
    s = s+g(x);
end

s = 1./s;
for x = -n:1:n
    
    g(x) = (g(x)*s);
    xg(x) = (x*g(x));
    xxg(x) = (x*x*g(x));
end

G = zeros(6,6);

for y = -n:1:n
    
    for x = -n:1:n
        G(0,0) = G(0,0) + g(y)*g(x);
        G(1,1) = G(1,1) + g(y)*g(x)*x*x;
        G(3,3) = G(3,3) + g(y)*g(x)*x*x*x*x;
        G(5,5) = G(5,5) + g(y)*g(x)*x*x*y*y;
    end
end

%G(0)(0) = 1.;
G(2,2) = G(1,1);
G(0,3) = G(1,1);
G(0,4) = G(1,1);
G(3,0) = G(1,1);
G(4,0) = G(1,1);

G(4,4) = G(3,3);
G(3,4) = G(5,5);
G(4,3) = G(5,5);
% invG:
% [ x        e  e    ]
% [    y             ]
% [       y          ]
% [ e        z       ]
% [ e           z    ]
% [                u ]
invG = inv(g);

ig11 = invG(1,1);
ig03 = invG(0,3);
ig33 = invG(3,3);
ig55 = invG(5,5);


end


%% -
function FarnebackPolyExp( src, dst, n, sigma )
% function FarnebackPolyExp( const Mat& src, Mat& dst, int n, double sigma )

% int k = 0;
% int x=0;
% int y=0;
[width,height] = size(src);

% int width = src.cols;
% int height = src.rows;
AutoBuffer<float> kbuf(n*6 + 3), var_row((width + n*2)*3);

g = kbuf.data() + n;
xg = g + n*2 + 1;
xxg = xg + n*2 + 1;
row = var_row.data() + n*3;
ig11=0;
ig03=0;
ig33=0;
ig55=0;

FarnebackPrepareGaussian(n, sigma, g, xg, xxg, ig11, ig03, ig33, ig55);

dst.create( height, width, CV_32FC(5));

for y = 0:(height-1)
    
    g0 = g;
    g1 = 0;
    g2 = 0;
    
%     const float *srow0 = src.ptr<float>(y)
% %     *srow1 = 0;
%     float *drow = dst.ptr<float>(y);
     
    srow0 = src(y,:);
    drow = dst(y,:);
    
    % vertical part of convolution
    for x = 0:(height-1)
        row(x*3) = srow0(x)*g0;
        row(x*3+1) = 0;
        row(x*3+2) = 0;
    end
    
    for k = 1:n %( k = 1; k <= n; k++ )
        g0 = g(k); 
        g1 = xg(k); 
        g2 = xxg(k);
        
        srow0 = max(y-k,0); %src.ptr<float>(max(y-k,0));
        srow1 = min(y+k,height-1); %src.ptr<float>(min(y+k,height-1));
        
        for x = 0:(width-1) %( x = 0; x < width; x++ )
            p = srow0(x) + srow1(x);
            t0 = row(x*3) + g0*p;
            ft1 = row(x*3+1) + g1*(srow1(x) - srow0(x));
            t2 = row(x*3+2) + g2*p;
            
            row(x*3) = t0;
            row(x*3+1) = t1;
            row(x*3+2) = t2;
        end
    end
    
    % horizontal part of convolution
    for x=0:(n*3-1) %( x = 0; x < n*3; x++ )
        row(-1-x) = row(2-x);
        row(width*3+x) = row(width*3+x-3);
    end
    
    
    for	x=0:(width-1) %( x = 0; x < width; x++ )
        g0 = g(0);
        % r1 ~ 1, r2 ~ x, r3 ~ y, r4 ~ x^2, r5 ~ y^2, r6 ~ xy
        b1 = row(x*3)*g0;
        b2 = 0;
        b3 = row(x*3+1)*g0;
        b4 = 0;
        b5 = row(x*3+2)*g0;
        b6 = 0;
        
        for k=1:n  %( k = 1; k <= n; k++ )
            
            tg = row((x+k)*3) + row((x-k)*3);
            g0 = g(k);
            b1 = b1 + tg*g0;
            b4 = b4 + tg*xxg(k);
            b2 = b2 + (row((x+k)*3) - row((x-k)*3))*xg(k);
            b3 = b3 + (row((x+k)*3+1) + row((x-k)*3+1))*g0;
            b6 = b6 + (row((x+k)*3+1) - row((x-k)*3+1))*xg(k);
            b5 = b5 + (row((x+k)*3+2) + row((x-k)*3+2))*g0;
        end
        
        % do not store r1
        drow(x*5+1) = (b2*ig11);
        drow(x*5) = (b3*ig11);
        drow(x*5+3) = (b1*ig03 + b4*ig33);
        drow(x*5+2) = (b1*ig03 + b5*ig33);
        drow(x*5+4) = (b6*ig55);
    end
    
    
    row = row - n*3;
    
end
end

%-------------------------------------------------------------------
function FarnebackUpdateMatrices( var_R0, var_R1,...
    var_flow,matM, var_y0, var_y1 )
% function FarnebackUpdateMatrices( const Mat& var_R0, const Mat& var_R1,...
%     const Mat& var_flow, Mat& matM, int var_y0, int var_y1 )

% const int BORDER = 5;
% static const float border[BORDER] = single([0.14, 0.14, 0.4472, 0.4472, 0.4472]);

BORDER = 5;
border = single([0.14, 0.14, 0.4472, 0.4472, 0.4472]);

% int x
% int y
width = var_flow.cols;
height = var_flow.rows;

const float* R1 = var_R1.ptr<float>();
size_t step1 = var_R1.step/sizeof(R1[0]);

matM.create(height, width, CV_32FC(5));

for y = var_y0:1:(var_y1-1) %( y = var_y0; y < var_y1; y++ )
    
    const float* flow = var_flow.ptr<float>(y);
    const float* R0 = var_R0.ptr<float>(y);
    float* M = matM.ptr<float>(y);
    
    for x=0:(width-1) %( x = 0; x < width; x++ )
        dx = flow(x*2);
        dy = flow(x*2+1);
        fx = x + dx;
        fy = y + dy;
        
        
        x1 = floor(fx);
        y1 = floor(fy);
        ptr = R1 + y1*step1 + x1*5;
%         float r2, r3, r4, r5, r6;
         
        fx = fx - x1;
        fy = fy- y1;
        
        if x1 < (width-1) && y1 < (height-1)
            
            a00 = (1-fx)*(1-fy);
            a01 = fx*(1-fy);
            a10 = (1-fx)*fy;
            a11 = fx*fy;
            
            r2 = a00*ptr(0) + a01*ptr(5) + a10*ptr(step1) + a11*ptr(step1+5);
            r3 = a00*ptr(1) + a01*ptr(6) + a10*ptr(step1+1) + a11*ptr(step1+6);
            r4 = a00*ptr(2) + a01*ptr(7) + a10*ptr(step1+2) + a11*ptr(step1+7);
            r5 = a00*ptr(3) + a01*ptr(8) + a10*ptr(step1+3) + a11*ptr(step1+8);
            r6 = a00*ptr(4) + a01*ptr(9) + a10*ptr(step1+4) + a11*ptr(step1+9);
            
            r4 = (R0(x*5+2) + r4)*0.5;
            r5 = (R0(x*5+3) + r5)*0.5;
            r6 = (R0(x*5+4) + r6)*0.25;
            
        else
            
            r2 = 0;
            r3 = 0;
            r4 = R0(x*5+2);
            r5 = R0(x*5+3);
            r6 = R0(x*5+4)*0.5;
        end
        
        r2 = (R0(x*5) - r2)*0.5;
        r3 = (R0(x*5+1) - r3)*0.5;
        
        r2 = r2+ r4*dy + r6*dx;
        r3 = r3+ r6*dy + r5*dx;
        
        if( (x - BORDER) >= (width - BORDER*2) || ...
                (y - BORDER) >= (height - BORDER*2))
            
            scale = (x < BORDER ? border(x) : 1.f)*...
                (x >= width - BORDER ? border(width - x - 1) : 1) *...
                (y < BORDER ? border(y) : 1.f)*...
                (y >= height - BORDER ? border(height - y - 1) : 1);
            
            r2 = r2* scale;
            r3 = r3* scale;
            r4 = r4* scale;
            r5 = r5 * scale;
            r6 = r6 * scale;
        end
        
        M(x*5)   = r4*r4 + r6*r6; % G(1,1)
        M(x*5+1) = (r4 + r5)*r6;  % G(1,2)=G(2,1)
        M(x*5+2) = r5*r5 + r6*r6; % G(2,2)
        M(x*5+3) = r4*r2 + r6*r3; % h(1)
        M(x*5+4) = r6*r2 + r5*r3; % h(2)
    end
end
end

%% -------------------------------------------------------------------
function FarnebackUpdateFlow_Blur(var_R0, var_R1,var_flow,matM,block_size,...
    update_matrices )
% function FarnebackUpdateFlow_Blur( const Mat& _R0, const Mat& _R1,...
%     Mat& _flow, Mat& matM, int block_size,...
%     bool update_matrices )

% int x = 0;
% int y = 0;
width = var_flow.cols;
height = var_flow.rows;

m = block_size/2;
y0 = 0;
y1 = 0;
min_update_stripe = max(bitshift(1,10)/width, block_size);
scale = 1./(block_size*block_size);

% AutoBuffer<double> var_vsum((width+m*2+2)*5);
vsum = zeros((m+1)*5,1);

% init vsum
srow0 = matM;
for x=0:(width*5-1)%( x = 0; x < width*5; x++ )
    vsum(x) = srow0(x)*(m+2);
end

for y=1:(m-1)   %( y = 1; y < m; y++ )
    srow0 = matM(1,min(y,height-1));
    for x=0:(width*5-1) %( x = 0; x < width*5; x++ )
        vsum(x) = vsum(x) + srow0(x);
    end
end

% compute blur(G)*flow=blur(h)
for y=0:(height-1) %( y = 0; y < height; y++ )
    
    %     double g11, g12, g22, h1, h2;
    %float* flow = var_flow.ptr<float>(y);
    flow = var_flow(y,:);
    srow0 = matM(max(y-m-1,0),:);
    srow1 = matM(min(y+m,height-1),1);
    
    % vertical blur
    for x=0:(width*5-1) %( x = 0; x < width*5; x++ )
        vsum(x) = vsum(x) + srow1(x) - srow0(x);
    end
    
    % update borders
    for x=0:(width*5-1) %( x = 0; x < (m+1)*5; x++ )
        
        vsum(-1-x) = vsum(4-x);
        vsum(width*5+x) = vsum(width*5+x-5);
    end
    
    % init g** and h*
    g11 = vsum(0)*(m+2);
    g12 = vsum(1)*(m+2);
    g22 = vsum(2)*(m+2);
    h1 = vsum(3)*(m+2);
    h2 = vsum(4)*(m+2);
    
    for x=1:(m-1) %( x = 1; x < m; x++ )
        g11 = g11 + vsum(x*5);
        g12 = g12 + vsum(x*5+1);
        g22 = g22 + vsum(x*5+2);
        h1 = h1 + vsum(x*5+3);
        h2 = h2 + vsum(x*5+4);
    end
    
    % horizontal blur
    for x=0:(width-1) %( x = 0; x < width; x++ )
        g11 = g11 + vsum((x+m)*5) - vsum((x-m)*5 - 5);
        g12 = g12 + vsum((x+m)*5 + 1) - vsum((x-m)*5 - 4);
        g22 = g22 + vsum((x+m)*5 + 2) - vsum((x-m)*5 - 3);
        h1 = h1 + vsum((x+m)*5 + 3) - vsum((x-m)*5 - 2);
        h2 = h2 + vsum((x+m)*5 + 4) - vsum((x-m)*5 - 1);
        
        g11_ = g11*scale;
        g12_ = g12*scale;
        g22_ = g22*scale;
        h1_ = h1*scale;
        h2_ = h2*scale;
        
        idet = 1./(g11_*g22_ - g12_*g12_+1e-3);
        
        flow(x*2) = (g11_*h2_-g12_*h1_)*idet;
        flow(x*2+1) = (g22_*h1_-g12_*h2_)*idet;
    end
    
    
    y1 = quest_op(y == height - 1,height,y - block_size);
    if( update_matrices && (y1 == height || y1 >= y0 + min_update_stripe) )
        FarnebackUpdateMatrices( var_R0, var_R1, var_flow, matM, y0, y1 );
        y0 = y1;
    end
end
end


%% -------------------------------------------------------------------
function FarnebackUpdateFlow_GaussianBlur(var_R0, var_R1,...
    var_flow, matM, block_size,update_matrices )
% function FarnebackUpdateFlow_GaussianBlur( const Mat& _R0, const Mat& _R1,...
% Mat& _flow, Mat& matM, int block_size,...
% bool update_matrices )

% x = 0;
% y = 0;
% i = 0;
% width = var_flow.cols;
% height = var_flow.rows;
[width,height] = size(var_flow);

m = block_size/2;
y0 = 0;
y1 = 0;
min_update_stripe = max(bitshift(1,10)/width, block_size);
sigma = m*0.3;
s = 1;



% AutoBuffer<float> var_vsum((width+m*2+2)*5 + 16), var_hsum(width*5 + 16);
% AutoBuffer<float> var_kernel((m+1)*5 + 16);
% AutoBuffer<const float*> var_srow(m*2+1);
% 
% float *vsum = alignPtr(var_vsum.data() + (m+1)*5, 16)
% float *hsum = alignPtr(var_hsum.data(), 16);
% float* kernel = var_kernel.data();
% const float** srow = var_srow.data();

kernel = zeros([m 1],'single');

for i=1:m %( i = 1; i <= m; i++ )
    
    t = exp(-i*i/(2*sigma*sigma) );
    kernel(i) = t;
    s = s+ t*2;
end

s = 1./s;
for i=0:m %( i = 0; i <= m; i++ )
    kernel(i) = (kernel(i)*s);
end

% compute blur(G)*flow=blur(h)
for y=0:(height-1) %( y = 0; y < height; y++ )
    
    g11 = 0;
    g12 = 0;
    g22 = 0;
    h1 = 0;
    h2 = 0;
    
    flow = var_flow(y,:);
    
    % vertical blur
    for	i=0:m %( i = 0; i <= m; i++ )
        
        srow(m-i) = matM.ptr<float>(max(y-i,0)); %matM.ptr<float>(max(y-i,0));
        srow(m+i) = matM.ptr<float>(min(y+i,height-1)); %matM.ptr<float>(min(y+i,height-1));
    end
    
%     x = 0;
    for x=0:(width*5-1)%; x < width*5; x++ )
        s0 = srow(m,x)*kernel(0);
        
        for i=1:m %( i = 1; i <= m; i++ )
            s0 = s0 + (srow(m+i,x) + srow(m-i,x) )*kernel(i);
        end
        
        vsum(x) = s0;
    end
    
    % update borders
    for x=0:(m*5-1)%( x = 0; x < m*5; x++ )
        
        vsum(-1-x) = vsum(4-x);
        vsum(width*5+x) = vsum(width*5+x-5);
    end
    
    % horizontal blur
    for x=0:(width*5-1) %( ; x < width*5; x++ )
        
        runsum = vsum(x)*kernel(0);
        for i=1:m %( i = 1; i <= m; i++ )
            runsum = runsum + kernel(i)*(vsum(x - i*5) + vsum(x + i*5));
        end
        
        hsum(x) = runsum;
    end
    
    for x=0:(width-1) %( x = 0; x < width; x++ )
        
        g11 = hsum(x*5);
        g12 = hsum(x*5+1);
        g22 = hsum(x*5+2);
        h1 = hsum(x*5+3);
        h2 = hsum(x*5+4);
        
        idet = 1./(g11*g22 - g12*g12 + 1e-3);
        
        flow(x*2) = (g11*h2-g12*h1)*idet;
        flow(x*2+1) = (g22*h1-g12*h2)*idet;
    end
    
    y1 = quest_op(y == height - 1,height,y - block_size);
    if( update_matrices && (y1 == height || y1 >= y0 + min_update_stripe) )
        
        FarnebackUpdateMatrices( var_R0, var_R1, var_flow, matM, y0, y1 );
        y0 = y1;
    end
    
end

end


%%
function out_value = quest_op(eval_statement,varargin)

    if eval_statement
        out_value = varargin{1};
    else
        out_value = varargin{2};
    end

end



%% -------------------------------------------------------------------
function optflow_calc(var_prev0,var_next0,var_flow0,varargin)
% function FarnebackOpticalFlowImpl::calc(InputArray var_prev0, InputArray var_next0,...
%     InputOutputArray var_flow0)


if any(contains(varargin,'gaussblur'))
    OPTFLOW_FARNEBACK_GAUSSIAN = true;
else
    OPTFLOW_FARNEBACK_GAUSSIAN = false;
end

Mat prev0 = var_prev0.getMat();
Mat next0 = var_next0.getMat();
min_size = 32;
const Mat* img[2] = { &prev0, &next0 };

% i = 0;
% k = 0;
scale = 1;
Mat prevFlow;
Mat flow;
Mat fimg;
levels = numLevels_;

if isempty(var_flow0)
    var_flow0 = zeros(size(prev0), 'single' ); %CV_32FC2
end
flow0 = var_flow0;


for k=0:(levels-1) %( k = 0, scale = 1; k < levels; k++ )
    scale = scale*pyrScale_;
    if( prev0.cols*scale < min_size || prev0.rows*scale < min_size )
        break;
    end
end


levels = k;

for k = levels:-1:0 %( k = levels; k >= 0; k-- )
    
    scale = 1;
    for i=0:(k-1) %( i = 0, scale = 1; i < k; i++ )
        scale = scale*pyrScale_;
    end
    
    sigma = (1./scale-1)*0.5;
    smooth_sz = round(sigma*5)|1;
    smooth_sz = max(smooth_sz, 3);
    
    width = round(prev0.cols*scale);
    height = round(prev0.rows*scale);
    
    if( k > 0 )
        %         flow.create( height, width, CV_32FC2 );
        flow = zeros([height width],'single');
    else
        flow = flow0;
    end
    
    if( prevFlow.empty() )
        if( flags_ && OPTFLOW_USE_INITIAL_FLOW )
            resize( flow0, flow, Size(width, height), 0, 0, INTER_AREA );
            flow = flow*scale;
        else
            flow = zeros([height width],'single'); %flow = zeros( height, width, CV_32FC2 );
        end
    else
        
        resize( prevFlow, flow, Size(width, height), 0, 0, INTER_LINEAR );
        flow = flow * 1./pyrScale_;
    end
    
    Mat R[2];
    Mat I;
    Mat M;
    for i = 0:1%( i = 0; i < 2; i++ )
        
        img(i)->convertTo(fimg, CV_32F);
        GaussianBlur(fimg, fimg, Size(smooth_sz, smooth_sz), sigma, sigma);
        resize( fimg, I, Size(width, height), INTER_LINEAR );
        FarnebackPolyExp( I, R(i), polyN_, polySigma_ );
    end
    
    FarnebackUpdateMatrices( R(0), R(1), flow, M, 0, flow.rows );
    
    for i=0:(numIters_-1)%( i = 0; i < numIters_; i++ )
        
        if( flags_ && OPTFLOW_FARNEBACK_GAUSSIAN )
            FarnebackUpdateFlow_GaussianBlur( R(0), R(1), ...
                flow, M, winSize_, i < (numIters_ - 1) );
        else
            FarnebackUpdateFlow_Blur( R(0), R(1), ...
                flow, M, winSize_, i < (numIters_ - 1) );
        end
    end
    
    prevFlow = flow;
    
end

end

