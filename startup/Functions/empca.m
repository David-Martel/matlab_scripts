function [u, s, v, a] = empca(a, varargin)%#codeden
%EMPCA	Expectation-Maximization Principal Component Analysis
%   [U, S, V] = EMPCA(A,N) calculates N principal components of matrix A,
%   and returns U, S, V that approximate the N-rank truncation of the
%   singular value decomposition of A. S is a diagonal matrix with singular
%   values corresponding to the contribution of each principal component to
%   matrix A. U and V have orthonormal columns. Matrix A is interpreted as
%   a 2D array. A can be a full or sparse matrix of class 'single',
%   'double', or 'gpuArray'. N must be a positive integer, and is reduced
%   to the minimum dimension of A if higher.
% 
%   [U, S, V, E] = EMPCA(A,N) also returns the residual error matrix E
%   resulting from the PCA decomposition, such that A == U*S*V' + E.
% 
%   [...] = EMPCA(A,N,TOL) keeps principal components when changes in U
%   during the last EM iteration are smaller than TOL, instead of the
%   default value of 1e-6. TOL must be a scalar.
% 
%   [...] = EMPCA(A,N,TOL,MAXITER) keeps principal components after MAXITER
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
    
%% functions
derp = 6;

% outerProd = @(A, B) reshape(A(:) * B(:).', [max(size(A)), max(size(B))]);
p = inputParser; %ncomps, emtol, maxiters
addRequired(p,'ncomps');
addOptional(p,'emtol',1e-6);
addOptional(p,'maxiters',100);

parse(p,a,varargin{:});

%% parameters
if ~isempty(p.Results.emtol)
    emtol = p.Results.emtol;
else
    emtol = 1e-6; % an eigenvector is found when max change in absolute eigenvector difference between EM iterations is below emtol
end

if ~isempty(p.Results.maxiters)
    maxiters = p.Results.maxiters;
else
    maxiters = 100; % an eigenvector is found when max change in absolute eigenvector difference between EM iterations is below emtol
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

if ~ismatrix(a)
    a = reshape(a,size(a,1),[]); % force it to be 2D
end
ncomps = min(p.Results.ncomps,min(size(a))); % reduce number of components if higher than maximum possible rank
%u  = gzeros(size(a,1),ncomps,aclass); % allocate memory for results
u = normc_local(grandn([size(a,1) ncomps],aclass));
sv = gzeros(size(a,2),ncomps,aclass);

% da = decomposition(a);
% figure(1); clf(1); hold on;
%% empca
for comp = 1:ncomps % for each component
%     u(:,comp) = normc(grandn([size(a,1) 1],aclass));
    u0 = u(:,comp)';
    u1 = u0;
%     error_store = nan(1,maxiters);
    for iter = 1:maxiters % repeat until u does not change or too many iterations
        u0 = u1; % store last iteration's u for comparison
        %sv(:,comp) = a'*u(:,comp); % E-step
        %u(:,comp) = normc_local(a*a'*u(:,comp)); % M-step

%         u1 = normc_local(u1'*a*a',2)';
% tic;
%         u1 = (u1*a)*a'; %
% %         normc_matrix();
%         u1 = rdivide(u1,sqrt(u1*u1'));
% toc;

        u1 = rdivide((u1*a)*a',vecnorm((u1*a)*a'));%sqrt(u1*u1')

        if all(u0-u1<=emtol) %max(abs(u0-u1)) <= emtol %all(abs(u1-u0)<=emtol) %all(u0-u1<=emtol) % check convergence
            break % iter
        end
    end
    %disp(['eigenvector ' num2str(comp) ' kept after ' num2str(iter) ' iterations'])
    u(:,comp) = u1';
    sv(:,comp) = a'*u(:,comp); 
    a = a - u1'*sv(:,comp)'; % update a removing converged component and leaving residual
    
%     sv(:,comp) = svt;
end
s = vecnorm(sv);
v = rdivide(sv,s);


%%
%normc_local = @(m,dim) rdivide(m,vecnorm(m,2,dim));
%     function normc_matrix()
%         u1 = rdivide(sig_scale,vecnorm(sig_scale,2))';
%     end

    function data = normc_local(data)
        data = rdivide(data,vecnorm(data));
    end

end

% derp = all(u0-u1<=emtol);
% any(u1>=emtol+u0)
% figure(1)
% clf(1)
% hold on
% plot(abs(u0-u1),'b')
% plot(emtol*ones(size(u0)),'r')
% plot(u0+emtol,'r')
% plot(u1,'b')
% plot(emtol*ones(size(u0)),'r')
% (u1*a*a')' = (a*a'*u1')


%%

% gpu = gpuDevice;
% 
% ag = gpuArray(a);
% u1g = gpuArray(u1);
% 
% tic;
% derpg = normc_local(ag*(ag'*u1g),1);
% toc;
% 
% tic;
% derpg2 = normc_local((u1g'*ag)*ag',2)';
% toc;

% u1t = u1';
% tic;
% sig_scale = a*(a'*u1);
% sig_scale2 = ((u1'*a)'*a)';

% norm_val = vecnorm(sig_scale,2,1);
% 
% derp2 = normc_local(a*(a'*u1),1);
% 
% toc;

% norm_val2 = vecnorm(sig_scale2',2,1);

% tic;
% derp = sig_scale;

% derp = normc_local(u1'*a*a',2)';


% sig_scale = sig_scale ./norm_val;
% toc;
% isequal(derp,derp2)
% sum((derp2-derp).^2)./length(derp2)

% derp = u1;
% tic;
%  derp = normc_local(derp,2)';
% toc;



% derp3 = u1;
% tic;
%derp2 = normc_local((u1'*a*a')',1);

% derp3 = normc_local((a')'*(derp3'*a)',1);
% 
%  toc;
% 
%  isequal(derp3,derp)
%  sum((derp3-derp).^2)./length(derp3)
% 
%      a*(a'*u1)
%     (a'*a)'*u1

% Matrix Addition and Matrix Multiplication
% A + B = B + A       (Commutative law of addition)
% A + B + C = A + ( B + C ) = ( A + B ) + C       (Associative law of addition)
% ABC = A( BC ) = ( AB )C       (Associative law of multiplication)
% A( B + C ) = AB + AC       (Distributive law of matrix algebra)
% x( A + B ) = xA + xB
% Transposition Rules
% ( A' )' = A
% ( A + B )' = A' + B'
% ( AB )' = B'A'
% (AB')' = BA'
% ( ABC )' = C'B'A'


% isequal((a'*u(:,comp))',u(:,comp)'*a)

% tic;
%         derp1 = a'*u(:,comp); % E-step
%         derp2 = normc_local(a*derp1); % M-step
% toc;
% 
% 
% %         derp11 = a'*u(:,comp); % E-step
%         %derp21 = normc_local((a')'*(u(:,comp)'*a)'); % M-step
%         tic;
%         derp21 = normc_local(((u(:,comp)'*a)*a'),2)'; % M-step
% 
%         toc;
%         tic;
%         %derp22 = normc_local(((u(:,comp)'*a)*a'),2)'; % M-step
% 
%         derp22 = normc_local(a*(a'*u(:,comp)),2); % M-step
%       toc;
%         %( AB )' = B'A'
% 
%         %A' = (u(:,comp)'*a)'
%         %B = a;
%         %((u(:,comp)'*a)*a')
% %         derp21 = normc_local(a*(u(:,comp)'*a)'); % M-step
% 
% 
% isequal(derp21,derp22)
% 
% 
% sum((derp2-derp21).^2)/length(derp2)
% 
% derp23 = outerProd(a,u(:,comp)'*a);
% 
% tic
% derp23 = outerProd(u1,svt);
% toc;
% 
% tic;
% derp3 = u1*svt';
% toc;
% 
% tic;
% derp4 = outerProd(u(:,comp),sv(:,comp));
% toc;
% isequal(derp23,derp3)
% 
% derp3 = sqrt(sum(sv.*sv));
% derp4 = vecnorm(sv,2);
% isequal(derp3,derp4)



% 
% end

% tic;
% derpnorm = sqrt(sum(sv.*sv));
% toc;
% 
% tic;
% derpnorm2 = vecnorm(sv,2);
% toc;
% 
% isequal(derpnorm,derpnorm2)
% 
% tic;
% derp = normc(a*sv(:,comp));
% toc;
% 
% tic;
% derp10 = normc2(a*sv(:,comp));
% toc;
% 
% tic;
% derp11 = normalize(a*sv(:,comp),'norm');
% toc
% 
% sum((derp-derp10).^2)/length(derp)
% 
% tic;
% derp3 = a*sv(:,comp);
% toc;
% 
% tic;
% derp4 = sqrt(sum((a*sv(:,comp)).*(a*sv(:,comp))));
% toc;
% 
% tic;
% derp5 = sqrt((a*sv(:,comp))'*(a*sv(:,comp)));
% toc;
% 
% tic;
% derp6 = sqrt(sv(:,comp)'*a'*(sv(:,comp)'*a')');
% %sv(:,comp)' = C , a' = B , (sv(:,comp)'*a')' = A
% % (C * B * A) ' --> (sv(:,comp)'*a' * a * sv(:,comp)
% 
% tic;
% derp7 = sqrt((sv(:,comp)' * a') * a * sv(:,comp)))
% %477x1,
% toc;
% 
% toc;
% tic;
% derp2 = rdivide(a*sv(:,comp),sqrt(sum((a*sv(:,comp)).*(a*sv(:,comp)))));
% toc;


