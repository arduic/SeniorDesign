function [y]=normalize(x, v1, v2)
    y = (x-min(x))/(max(x)-min(x)) * (v2 - v1) - v1;
end