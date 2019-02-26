function [ Bh, Bs, Dw, luck, last, published ] = stnum2st(num)
global maxBmore;
% stnum = ((((Bh*more+Bs)*(maxB+2)+Dw)*2+luck)*2+last)*more+published;
% state num must start with 1, not 0!
published = mod(num, maxBmore);
num = floor(num/maxBmore);
last = mod(num, 2);
num = floor(num/2);
luck = mod(num, 2);
num = floor(num/2);
Dw = mod(num, maxBmore);
num = floor(num/maxBmore);
Bs = mod(num, maxBmore);
Bh = floor(num/maxBmore);
end