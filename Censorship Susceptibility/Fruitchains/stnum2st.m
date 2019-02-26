function [ab, hb, hf, last] = stnum2st(num)
global maxForkLen maxafa maxhf timeOut
num = num - 1;
last = mod(num, 2);
num = floor(num/2);
hf = mod(num, maxhf+1);
num = floor(num/(maxhf+1));
hb = mod(num, maxForkLen+1);
ab = floor(num/(maxForkLen+1));
end