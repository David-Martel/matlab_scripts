function [ip_struct] = get_ipconfig()


[status,response] = system('ipconfig /all');

if status == 0
    %response = replace(response,', ',', ');
    ip_struct = struct;
    response_parts = regexp(response,'[\n]{2,}','split');
    num_parts = length(response_parts);
    
    iter = 1;
    for network_iter = 1:num_parts
        
        resp_part = response_parts{network_iter};
        
        if contains(resp_part,{'adapter',' configuration','*'},'ignorecase',true) && ...
                ~contains(resp_part,{'media state','dns suffix'},'ignorecase',true)
            ip_struct(iter).adapter = replace(resp_part,{newline,' ','*','.',':'},'');
        elseif contains(resp_part,{'address','media state','dns suffix'},'ignorecase',true)
            
            resp_part = regexprep(resp_part,'\n([ ]{4,})',',');
            resp_part = regexprep(resp_part,'[ ]','');
            resp_part = regexprep(resp_part,'\.{2,}:',':');
            resp_part = regexprep(resp_part,':\n',':Empty\n');
            
            resp_parts = regexp(resp_part,'\n','split');
            
            resp_parts(cellfun('isempty',resp_parts)) = [];
            
            for resp_iter = 1:length(resp_parts)
                
                comp_part = resp_parts{resp_iter};
                
                comp_part = replace(comp_part,{'-','.:','(Preferred)'},{'',':',''});
                
                
                if ~isempty(regexp(comp_part,'Address:','match','once'))
                    comp_parts = strsplit(comp_part,'Address:');
                    comp_parts{1} = [comp_parts{1} 'Address'];
                    
                elseif ~isempty(regexp(comp_part,'DNSServers','match','once'))
                    comp_parts = strsplit(comp_part,'DNSServers:');
                    comp_parts{1} = 'DNSServers';
                    
                elseif ~isempty(regexp(comp_part,'Gateway','match','once'))
                    comp_parts = strsplit(comp_part,'Gateway:');
                    comp_parts{1} = 'Gateway';
                else
                    comp_parts = strsplit(comp_part,':');
                end
                ip_struct(iter).(comp_parts{1}) = comp_parts{2};
            end
            
            
        end
        
        if mod(network_iter,2) == 0
            iter = iter + 1;
        end
        
    end
    
else
    ip_struct = [];
end

