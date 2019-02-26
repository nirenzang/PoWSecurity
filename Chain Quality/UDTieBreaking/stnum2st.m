function [a, h, tie] = stnum2st(num)
global maxForkLen
% stnum=(a*(maxForkLen+1)+h)*2+fork;
tie = mod(num, 2);
num = floor(num/2);
h=mod(num, maxForkLen+1);
a=floor(num/(maxForkLen+1));
end