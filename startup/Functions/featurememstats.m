function info = featurememstats(cls, unit)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% info = featurememstats
%
% Return same information than with Matlab command feature('memstats')
% but in structure form. Work on PC only.
%
% Optional ouput controls: info = featurememstats(class, unit) 
% CLASS is class of the output, 
%    CLASS must be in { ['double'] 'uint32' 'uint64' 'int32' 'int64' }
% UNIT is either
%    UNIT must be in{ { ['byte'], 'kbyte', 'Mbyte' } or
%    a numerical value (e.g., 1024 for kbyte)
%
% Note1: returned values are round to closest integer (as in ROUND)
% 
% Note2:
%  - on PCx32 platform ( strcmp(computer,'PCWIN') == true),
%    the largest "true" contiguous memory block is first record
%                   info.LargestContiguousFreeBlocks.Block(1).
%  - on PCx64 platform ( strcmp(computer,'PCWIN64') == true),
%    the largest "true" contiguous memory block is SECOND record
%                   info.LargestContiguousFreeBlocks.Block(2).
%
% Matlab compatibility: should work on 2006B-2008B (probably
%                       other version too but not warranty)
% Author: Bruno Luong
%         b.luong@fogale.fr
% Orginal: 21/Oct/2008
% update: 22/Oct/2008, correct bug for sscanf, unable to convert an
%         hexa string with more than 8 characters (size >= 4Gbytes) 
%         Do not use unit to scan pointer address
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% default class
if nargin<1 || isempty(cls)
    cls='double';
end
if nargin<1 || isempty(cls)
    unit='double';
end
% Retreive unit
if nargin>=2 && ischar(unit)
    % Check validity of unit
    switch lower(unit)
        case {'b' 'byte' 'bytes'}
            unit = 1;
        case {'k' 'kb' 'kbyte' 'kbytes'}
            unit = 1024;
        case {'m' 'mb' 'mbyte' 'mbytes'}
            unit = 1024^2;
        otherwise
            error('featurememstats: incorrect unit %s', unit);
    end
else
    if nargin<2 || isempty(unit) || ~isnumeric(unit) || unit<=0
        unit = 1;
    end
end
% Check validity of cls
if ischar(cls)
    classvalid = strfind({'double' 'uint32' 'uint64' 'int32','int64'}, ...
        lower(cls));
    if all(cellfun(@isempty,classvalid))
        error('featurememstats: incorrect class %s', cls);
    end
else
    error('featurememstats: first input must be a class name');
end
if ~ispc()
    error('featurememstats: PC only');
end
% Call Matlab to get an info
% Work only on PC
str = evalc('feature(''memstats'')');
% Example: of str output
%     Physical Memory (RAM):
%         In Use:                              966 MB (3c6db000)
%         Free:                               1078 MB (436d6000)
%         Total:                              2045 MB (7fdb1000)
%     Page File (Swap space):
%         In Use:                             1329 MB (53120000)
%         Free:                               3001 MB (bb98b000)
%         Total:                              4330 MB (10eaab000)
%     Virtual Memory (Address Space):
%         In Use:                              725 MB (2d5cd000)
%         Free:                               1322 MB (52a13000)
%         Total:                              2047 MB (7ffe0000)
%     Largest Contiguous Free Blocks:
%          1. [at 2a8a0000]                   1002 MB (3ea50000)
%          2. [at 7c396000]                     51 MB ( 335a000)
%          3. [at 6d43d000]                     41 MB ( 2933000)
%          4. [at 268d0000]                     16 MB ( 1000000)
%          5. [at 7034f000]                     12 MB (  c71000)
%          6. [at 716fb000]                      9 MB (  9c5000)
%          7. [at 7b9a3000]                      9 MB (  99d000)
%          8. [at 290a0000]                      8 MB (  830000)
%          9. [at 6b06b000]                      8 MB (  815000)
%         10. [at 24cd0000]                      8 MB (  800000)
%                                             ======= ==========
%                                             1166 MB (48ef5000)
% Split string in separate lines
str = regexp(str,'\n','split');
info=[];
fieldtree = {};
blockcount = 0;
% Loop over the lines
for i=1:length(str)
    line = str{i};
    % First nonspace char
    nospace = regexp(line,  '(\S)', 'once'); % location
    if ~isempty(nospace)
        % Get field name and values
        [field, val]= parsingline(line, cls, unit);
            
        if ~isempty(field)
            if nospace<=5 % count the number of spaces to know
                          % the tree structure level!!! 
                level=1; % mainfield
            else % nospace 9 or 10
                level=2; % subfield
            end
            fieldtree{level} = field; %#ok
            fieldtree(level+1:end)=[]; % remove trailing
        else
            level=0; % nofield
        end
        
        % Add field and value into the info
        if level>0 && ~isempty(val)
            % build structure for subsasgn
            dot(1:level)={'.'};
            ssarg = [dot; fieldtree];
            if strcmp(field,'Block') % array
                blockcount=blockcount+1;
                ssarg(:,end+1) = {'()'; {blockcount}};
            end
            % Assign value to field/subfield of info
            info = subsasgn(info, substruct(ssarg{:}), val);
        elseif level==0 && ~isempty(val) % Total
            % similar to
            % sum([info.LargestContiguousFreeBlocks.Block.size])
            info.('TotalBlocks') = val;
        end % if level>0 && ~isempty(val) 
    end % if ~isempty(nospace)
    
end % for-loop on line
end % featurememstats(cls)
function [field val]= parsingline(str, cls, unit)
% function [field val]= parsingline(str, cls)
% Get the fieldname and value from a string of a line
%
str = strtrim(str);
semicolumn = strfind(str,':'); % Look for semicolumn
if ~isempty(semicolumn) % found it
    firstpart = str(1:semicolumn(1)); % Before semicolumn
    lastpart = str(semicolumn(end):end); % After semicolumn
     % Remove garbage: spaces and comment in "(...)"
    field = regexprep(firstpart, {' ' '\(\w*\)' ':'},'');
else % no semicolumn
    field = '';
    lastpart = str; % Last part as whole string
end
% hexa inside parenthesis such as "( 335a000)"
val = regexp(lastpart,'\([\sa-fA-F0-9]+\)','match');
if ~isempty(val)
    val = scanstr(val{1}(2:end-1),cls,unit);
else
    val = [];
end
 % hexa in bracket such as "[at 2a8a0000]"
adr = regexp(lastpart,'\[(at\s)[\sa-fA-F0-9]+\]','match');
if ~isempty(adr)
    adr = scanstr(adr{1}(5:end-1),cls,1);
    field='Block';
    % return a structure, val must defined at this point
    val = struct('size', val, 'at', adr);
end
    
end % of parsingline
function res = scanstr(str, cls, unit)
% function res = scanstr(str, cls, unit)
% convert hexa string to value with appropriate class and unit
str=strtrim(str);
if length(str)<=8 % Smaller that 4 Gbytes
    res = feval(cls,round(sscanf(str,'%x')/unit));
else % larger than 4 Gbytes, truncate string, MATLAB is not able to scan
     % integer number with more than 32 bits
    l = length(str);
    str = str(1:8);
    res = feval(cls,round(sscanf(str,'%x')/(unit/16^(l-8))));
end
end % of scanstr
