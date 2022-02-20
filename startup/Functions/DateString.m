function DS = DateString
% Get todays date in 6 digit string format.
tempdate = string(datevec(date));
if length(tempdate{2}) == 1
    tempdate{2} = ['0' char(tempdate(2))];
end
if length(tempdate{3}) == 1
    tempdate{3} = ['0' char(tempdate(3))];
end
Date = char(strcat(tempdate(1), tempdate(2), tempdate(3)));
DS = Date(3:end);
end

