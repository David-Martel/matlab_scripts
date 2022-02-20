        %Generate a unique sorted list of numerical values associated with
        %the requested epoc
        function [Output] = SortedEpocs(obj,EpocType,varargin)

            if ~isfield(obj,'tind')
               output = 1; 
            end
            if isempty(varargin)
                Output=unique(obj.Epocs.Values.(EpocType));
            else
                trials=varargin{1};
                Output=unique(obj.Epocs.Values.(EpocType)(trials));
            end
            
        end
