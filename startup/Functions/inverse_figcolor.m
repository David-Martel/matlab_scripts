function inverse_figcolor(fig_handle)



h=get(fig_handle,'children');
for i=1:length(h)
    set(h(i),'color','none');
    try h(i).Color=1-h(i).Color;    end
    try h(i).GridColor=1-h(i).GridColor; end
    h(i).XColor=1-h(i).XColor;
    h(i).YColor=1-h(i).YColor;
    h(i).ZColor=1-h(i).ZColor;
    hh=get(h(i),'children');
    for j=1:length(hh)
       try  hh(j).Color=1-hh(j).Color; end
       try  hh(j).MarkerFaceColor=1-hh(j).MarkerFaceColor;	end
       try  hh(j).FaceColor=1-hh(j).FaceColor;    end
       try  hh(j).EdgeColor=1-hh(j).EdgeColor;    end
    end
end




end