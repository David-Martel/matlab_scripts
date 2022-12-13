
function z = probe_map(channel_list,varargin)

% channel_list=1:32
% channel_list=unit_sp.ch
% optional input:
% depth=6800;
%
% OUTPUT: z (2x2 double) first col=channel_list; second col=depth;


if ~isempty(varargin)
    depth=varargin{1};
else
    depth=0;
end

if max(channel_list)<=16
    probemap=[1 9;8 16;2 10;7 15;3 11;6 14;4 12;5 13];
    probemap(:,3)=[0:125:125*7]+50;
elseif max(channel_list)>16
    probemap=[1 9 2 10 8 16 3 11 4 12 7 15 5 13 6 14]';
    probemap=[probemap probemap+16];
    probemap=flipud(probemap);
    probemap(:,3)=[0:100:100*15]+50;
end
    

for m=1:length(channel_list)
    [i,j]=find(probemap==channel_list(m));
    depthmat(m,1)=depth-probemap(i,3);
end

z=depthmat;


end