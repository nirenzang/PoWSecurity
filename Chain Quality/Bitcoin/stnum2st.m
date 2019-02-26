function [ a, h, fork ] = stnum2st( num)
global maxForkLen
% input num, output a, h, fork
num = num - 1;
fork=mod(num, 3);
temp=floor(num/3);
h=mod(temp, maxForkLen+1);
a=floor(temp/(maxForkLen+1));
end