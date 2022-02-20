function [digit_idx] = containsDigits(input_str)

if isempty(input_str)
    digit_idx = [];
else
    zero_char = 48;
    nine_char = 48+9;
    
    neg_char = 45;
    decimal_char = 46;
    
    character_list = uint8(char(input_str));
    
    digit_idx = (character_list>=zero_char & character_list<=nine_char) | ...
        ismember(character_list,[neg_char decimal_char]);
    
end
