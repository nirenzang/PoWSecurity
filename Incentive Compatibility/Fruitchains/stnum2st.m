function [ab, hb, afA, hf, last] = stnum2st(num)
global maxForkLen maxafa maxhf timeOut
num = num - 1;
last = mod(num, 2);
num = floor(num/2);
hf = mod(num, maxhf+1);
num = floor(num/(maxhf+1));
hb = mod(num, maxForkLen+1);
num = floor(num/(maxForkLen+1));
if num<timeOut
    ab = num; afA = 0;
else
    num = num-timeOut;
    afA = mod(num, maxafa+1);
    ab = floor(num/(maxafa+1))+timeOut;
end
end