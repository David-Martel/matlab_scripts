function token_str = get_new_machine_token()

token_str = '';

good_users = {'damartel','davidmartel07','david'};

cur_user = getenv('username');

if ismember(cur_user,good_users)
    token_str = '37635629A1E5FC83CDBE2D061B6DCFB3';
end














