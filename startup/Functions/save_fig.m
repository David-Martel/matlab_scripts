function save_fig(path)


h=get(0,'children');
set(h,'paperpositionmode','auto');
% set(h,'paperorientation','landscape');

pp=get(h,'innerposition');
set(h,'paperunit','points')
set(h,'papersize',pp(3:4))

str=path(end-2:end);

ftype=['-d' str];

print(path,ftype,'-painters','-loose')


% close(h)
fprintf('saved.\n')

end