% For an image, {\displaystyle \Omega }\Omega , with discrete pixels, a discrete algorithm is required.
% 
% {\displaystyle u(p)={1 \over C(p)}\sum _{q\in \Omega }v(q)f(p,q)}u(p)={1 \over C(p)}\sum _{{q\in \Omega }}v(q)f(p,q)
% where {\displaystyle C(p)}C(p) is given by:
% 
% {\displaystyle C(p)=\sum _{q\in \Omega }f(p,q)}C(p)=\sum _{{q\in \Omega }}f(p,q)
% Then, for a Gaussian weighting function,
% 
% {\displaystyle f(p,q)=e^{-{{\left\vert B(q)-B(p)\right\vert ^{2}} \over h^{2}}}}f(p,q)=e^{{-{{\left\vert B(q)-B(p)\right\vert ^{2}} \over h^{2}}}}
% where {\displaystyle B(p)}B(p) is given by:
% 
% {\displaystyle B(p)={1 \over |R(p)|}\sum _{i\in R(p)}v(i)}B(p)={1 \over |R(p)|}\sum _{{i\in R(p)}}v(i)
% where {\displaystyle R(p)\subseteq \Omega }R(p)\subseteq \Omega  and is a square region of pixels surrounding {\displaystyle p}p and {\displaystyle |R(p)|}|R(p)| is the number of pixels in the region {\displaystyle R}R.