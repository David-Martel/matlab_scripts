


qr_code_api = 'http://api.qrserver.com/v1/create-qr-code/';

string_to_encode = 'Herro worrd!';
data_str = '?data=[URL-encoded-text]';
data_str = strrep(data_str,'[URL-encoded-text]',string_to_encode);

pixel_size = 150;
size_str = 'size=[pixels]x[pixels]';
size_str = strrep(size_str,'[pixels]',num2str(pixel_size));

char_source = 'UTF-8';
char_source_str = 'charset-source=[CHAR_TYPE]';
char_source_str = strrep(char_source_str,'[CHAR_TYPE]',char_source);

commands = {data_str,size_str,char_source_str};

get_qr_code = [qr_code_api strjoin(commands,'&')];

opt = weboptions;
img = webwrite(get_qr_code,opt);



imshow(logical(img))


