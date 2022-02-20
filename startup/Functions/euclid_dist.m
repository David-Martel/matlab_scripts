function dist = euclid_dist(x)

dist = sqrt(sum(diff(x).^2));