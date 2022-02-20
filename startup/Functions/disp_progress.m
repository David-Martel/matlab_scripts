function disp_progress(i,L)

% S=matlab.desktop.commandwindow.size; S=S(1)*0.9;
% clc
% fprintf('%s %d%% \n',repmat('|',1,round(S*i/L)),round(i/L*100))
    
S=matlab.desktop.commandwindow.size; S=floor(S(1)*0.9);

if L>=S
    step_array = linspace(1,S,L);
    [~,b,~]=unique(round(step_array));
    if ismember(i,b)
        fprintf('|');
    end
else
    pl = round(S/L);
    fprintf('%s',repmat('|',1,pl));
end



if i==L
   fprintf(' 100%%'); 
   fprintf('\n'); 
end


end

