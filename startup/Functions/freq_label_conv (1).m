function output = freq_label_conv(input)

if isa(input,'char')
    switch input
        case 'eight_ten'
            output = 8;
        case 'twelve_fourteen'
            output = 12;
        case 'sixteen_eighteen'
            output = 16;
        case 'twenty_thirty'
            output = 20;
        case 'BBN'
            output = 0;
    end
    
elseif isnumeric(input)
    
    switch input
        case 0
            output = 'BBN';
        case 8
            output = 'eight_ten';
        case 12
            output = 'twelve_fourteen';
        case 16
            output = 'sixteen_eighteen';
        case 20
            output = 'twenty_thirty';
    end
    
else
    output = nan;
end
    

















