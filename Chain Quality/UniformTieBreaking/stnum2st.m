function [a, h, fork] = stnum2st(num)
global maxForkLen
% stnum=(a*(maxForkLen+1)+h)*2+fork;
fork = mod(num, 2);
num = floor(num/2);
h=mod(num, maxForkLen+1);
a=floor(num/(maxForkLen+1));
end