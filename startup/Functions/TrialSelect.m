%Returns a list of trials having the requested parameters
% e.g. SelectedTrials = TrialSelect(sst.sst_sorted{1, 1},'mdp1',MDepths(iii),'mfr1',MFreqs(ii),'Lev2',0),
function [trials]=TrialSelect(obj,varargin) %#ok<STOUT>
% Generates a unique list of trials corresponding to requested
% stimulus parameters. Requested parameters act as a logical
% AND.
%
% These values should be as follows: 'Block',[1 3 5],'Lev1',[0 5
% 10],'Frq1',[1000 2000],... All
%
% When called without inputs, function returns a list of all
% trials available to the superspiketrain object.
%
% Use this function in conjunction with SortedEpocs and
% GetSpikes for maximally efficient data sorting.

if isempty(varargin)
    %                stats = grpstats(obj.Epocs.Values,obj.EpocNames,{'numel'});
    %                varargout{:,:} = stats(:,1:1+length(obj.EpocNames()));
    trials = 1:obj.NTrials;
    return;
end

warning off; %#ok<WNOFF>
Parameter=varargin(1:2:end);
Value=varargin(2:2:end);
for j=1:length(Parameter)
    In.(lower(Parameter{j}))=Value{j};
end
warning on; %#ok<WNON>

if ~ismember('tind',obj.EpocNames)&isfield(In,'tind')
    In=rmfield(In,'tind');
end

EpocNamesL=fieldnames(In);
findList=[];

for i = 1:length(EpocNamesL)
    findList=[findList; find(ismember(obj.Epocs.Values.(EpocNamesL{i}),In.(EpocNamesL{i})) ) ];
end
findCount=hist(findList,1:1:obj.NTrials);
trials=find(findCount==length(EpocNamesL));

if isempty(trials)
    trials=nan;
end



end