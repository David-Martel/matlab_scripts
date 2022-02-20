function outDS=mergeDS(GroupName,varargin)
% function outDS=mergeDS(GroupName,varargin)
% Function to merge multiple datasets.  Input must be a list of datasets to
% merge in the following format.  Group Name must be a cell array of one or
% more strings to use as VarNames for the dataset.  Key1, Key2, etc. must
% supply the values to put into each VarNames identification column in a cell array of strings the same size as GroupName. 
% mergeDS(Key1,DS1,Key2,DS2,...)

tempDS=[];
tempGroup=[];
outDS=[];

for k=1:2:nargin-1
    tempDS=varargin{k+1};
    tempGroup=dataset;
    for j=1:length(GroupName)
        tempGroup.(GroupName{j})(1:size(tempDS,1),1)=varargin{k}(j);
        tempGroup.(GroupName{j})=nominal(tempGroup.(GroupName{j}));
    end

        tempDS=cat(2,tempGroup,tempDS);    
        outDS=set(outDS,'ObsNames',{});
        tempDS=set(tempDS,'ObsNames',{});
        outDS=cat(1,outDS,tempDS);
end
end