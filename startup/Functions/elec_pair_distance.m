function dist = elec_pair_distance(ch1,ch2)

num_chan_shank = 16;
site_scale = 1;
num_shanks = 2;
width_scale = 4;

total_sites = num_chan_shank*num_shanks;
if (ch1>total_sites || ch2>total_sites) && (ch1<=num_chan_shank || ch2<=num_chan_shank)
    dist = nan;
    return
end

if ch1 > total_sites
    ch1 = ch1 -total_sites;
end
if ch2 > total_sites
    ch2 = ch2 - total_sites;
end

if ch1 == ch2
    dist = 0;
    return
end

col1 = [9;8;10;7;11;6;12;5;13;4;14;3;15;2;16;1];
col2 = col1+num_chan_shank;

%both on same shank
if (ch1<=num_chan_shank && ch2<= num_chan_shank) || (ch1>=(num_chan_shank+1)&&ch2>=(num_chan_shank+1))
    pos1 = find(col1==(mod(ch1-1,num_chan_shank)+1));
    pos2 = find(col1==(mod(ch2-1,num_chan_shank)+1));
    
    dist = site_scale*abs(pos1-pos2);
    
else
    %both on different shanks
    if ch1 <= num_chan_shank
        pos1 = find(col1==ch1);
    else
        pos1 = find(col2==ch1);
    end
    
    if ch2 <= num_chan_shank
        pos2 = find(col1==ch2);
    else
        pos2 = find(col2==ch2);
    end
    
    height = (site_scale*(pos2-pos1)).^2;
    width = (site_scale*width_scale).^2;
    dist = sqrt(height+width);
    
end













