function char_array = keepDigits(char_array)

keep_chars = ['-' strjoin(arrayfun(@num2str,0:9,'uniformoutput',false),'')];
char_array(~ismember(char_array,keep_chars)) = [];

