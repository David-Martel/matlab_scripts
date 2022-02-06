function [u, s, v, a] = empca_w(a, w, ncomps, emtol, maxiters)
%EMPCA	Expectation-Maximization Principal Component Analysis
%   [U, S, V] = EMPCA(A,W,N) calculates N principal components of matrix A,
%   using weight matrix W.
%   Returns U, S, V that approximate the N-rank truncation of the singular
%   value decomposition of A. S is a diagonal matrix with singular values
%   corresponding to the contribution of each principal component to matrix
%   A. U and V have orthonormal columns. Matrix A is interpreted as a 2D
%   array. A can be a full or sparse matrix of class 'single', 'double', or
%   'gpuArray'. N must be a positive integer, and is reduced to the minimum
%   dimension of A if higher.
% 
%   [U, S, V, E] = EMPCA(A,W,N) also returns the residual error matrix E
%   resulting from the PCA decomposition, such that A == U*S*V' + E.
% 
%   [...] = EMPCA(A,W) calculates all the components.
% 
%   [...] = EMPCA(A,W,N,TOL) keeps principal components when changes in U
%   during the last EM iteration are smaller than TOL, instead of the
%   default value of 1e-6. TOL must be a scalar.
% 
%   [...] = EMPCA(A,W,N,TOL,MAXITER) keeps principal components after MAXITER
%   EM iterations if convergence has not been reached. If omitted, a
%   maximum of 100 EM iterations are computed. MAXITER must be a positive
%   integer.
% 
%   This function implements the expectation maximization principal
%   component analysis algorithm by Stephen Bailey, available in 
%   http://arxiv.org/pdf/1208.4122v2.pdf
% 
%   Bailey, Stephen. "Principal Component Analysis with Noisy and/or
%   Missing Data." Publications of the Astronomical Society of the Pacific
%   124.919 (2012): 1015-1023.
% 
%   2014 Vicente Parot
%   Cohen Lab
%   Harvard University
% 
%% notes
% keep notation from a = u*s*v'.
% regarding empca paper notation:
%   x   : a
%   phi : u
%   c   : sv
%   
    
%% parameters
if ~exist('emtol','var')
    emtol = 1e-6; % an eigenvector is found when max change in absolute eigenvector difference between EM iterations is below emtol
end
if ~exist('maxiters','var')
    maxiters = 100; % or when maxiters is reached, whatever first
end
if isa(a,'gpuArray')
    gzeros = @gpuArray.zeros;
    grandn = @gpuArray.randn;
    aclass = classUnderlying(a);
else
    gzeros = @zeros;
    grandn = @randn;
    aclass = class(a);
end
emtol = max(emtol,eps(aclass));  % make sure emtol is not below eps
a = reshape(a,size(a,1),[]); % force it to be 2D
if ~exist('ncomps','var')
    ncomps = min(size(a)); % set to max rank if not specified
else
    warning 'ncomps reduced to max rank'
    ncomps = min(ncomps,min(size(a))); % reduce if higher than maximum possible rank
end
u  = gzeros(size(a,1),ncomps,aclass); % allocate memory for results
sv = gzeros(size(a,2),ncomps,aclass);
normc = @(m)bsxfun(@rdivide,m,sqrt(sum(m.^2))); % returns normalized columns
% w = ~isnan(a);
% a(~w) = 0;
%% empca
for comp = 1:ncomps % for each component
    u(:,comp) = normc(grandn([size(a,1) 1],aclass));
    for iter = 1:maxiters % repeat until u does not change or too many iterations
        u0 = u(:,comp); % store last iteration's u for comparison
        
        sv(:,comp) = a'*u(:,comp); % E-step
        % M-step with weights
        svw = bsxfun(@times,sv(:,comp),w'); % M-step
        u(:,comp) = sum(a.*svw',2)./(svw'*sv(:,comp)); % M-step
        u(:,comp) = normc(u(:,comp)); % M-step
        
        if max(abs(u0-u(:,comp))) <= emtol % check convergence
            break % iter
        end
    end
    disp(['eigenvector ' num2str(comp) ' kept after ' num2str(iter) ' iterations'])
    %%
    a = a - u(:,comp)*sv(:,comp)'; % update A, removing converged component and leaving residual
    a(~w) = 0;
end
% a(~w) = NaN;
s = diag(sqrt(sum(sv.^2)));
v = normc(sv);
