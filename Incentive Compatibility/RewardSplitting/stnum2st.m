function [a, h, fork, history] = stnum2st(num)
global tillaSmaller maxHistoryPlus1;
% stnum = (h*(h-1)/2+a)*maxHistoryPlus1+history+1;
if num<=tillaSmaller
    num = num-1;
    history = mod(num, maxHistoryPlus1);
    num = floor(num/maxHistoryPlus1);
    h = floor((1+sqrt(8*num+1))/2);
    a = num-h*(h-1)/2;
    fork = 0;
% stnum = tillaSmaller+(((a+2)*(a-1)/2+h)*3+fork)*maxHistoryPlus1+history+1;
else
    num = num-tillaSmaller-1;
    history = mod(num, maxHistoryPlus1);
    num = floor(num/maxHistoryPlus1);
    fork = mod(num, 3);
    num = floor(num/3);
    a = floor((-1+sqrt(8*num+9))/2);
    h = num-(a+2)*(a-1)/2;
end
end