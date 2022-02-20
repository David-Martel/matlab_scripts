function freq_code = freqstr2code(freq_str)

if isa(freq_str,'char')

    freq_str = replace(freq_str,'-','_');
    
    switch freq_str
        case 'BBN'
            freq_code = 0;
        case 'eight_ten'
            freq_code = 8;
        case 'twelve_fourteen'
            freq_code = 12;
        case 'sixteen_eighteen'
            freq_code = 16;
        case 'twenty_thirty'
            freq_code = 20;
        case 'three_six'
            freq_code = 3;
        case 'six_twelve'
            freq_code = 6;
        case 'twelve_twentyfour'
            freq_code = 12;
        case 'twentyfour_fortyeight'
            freq_code = 24;
            
        otherwise
            freq_code = nan;
    end
    
elseif isa(freq_str,'double')
    
    switch freq_str
        case 0
            freq_code = 'BBN';
        case 8
            freq_code = '8-10';
%         case 12
%             freq_code = '12-14';
        case 16
            freq_code = '16-18';
        case 20
            freq_code = '20-30';
        case 3
            freq_code = '3-6';
        case 6
            freq_code = '8-10';
        case 12
            freq_code = '12-24';
        case 24
            freq_code = '24-48';
            
        otherwise
            freq_code = 'miss';
    end
    
    
    
end

















