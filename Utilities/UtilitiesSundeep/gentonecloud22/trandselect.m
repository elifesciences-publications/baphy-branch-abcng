function xselect=trandselect(x)
%picks out one of the values of x, with equal probabilities

xselect=x(trand(length(x)));