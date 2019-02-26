function [a, h, tie, slot1, slot2] = stnum2st(num)
global range
global tillaSmaller tillaEqual tillaOneBigger;
if num<=tillaSmaller
    % stnum = (h*(h-1)/2+a)*range+slot1+1;
    tie = 0; slot2 = -1;
    slot1 = mod(num-1, range);
    num = floor((num-1)/range);
    h = floor((1+sqrt(8*num+1))/2);
    a = num-h*(h-1)/2;
elseif num<=tillaEqual
    % stnum = tillaSmaller+(a-1)*2+tie+1;
    slot1 = -1; slot2 = -1;
    num = num-tillaSmaller;
    tie = mod(num-1,2);
    a = floor((num-1)/2)+1;
    h = a;
elseif num<=tillaOneBigger
    % stnum = tillaEqual+((a-1)*2+tie)*range+slot1+1;
    slot2 = -1;
    num = num-tillaEqual-1;
    slot1 = mod(num, range);
    num = floor(num/range);
    tie = mod(num, 2);
    a = floor(num/2)+1;
    h = a-1;
else
    % stnum = tillaOneBigger+(((a-2)*(a-1)/2+h)*range+slot1)*range+slot2+1;
    tie = 0;
    num = num-tillaOneBigger-1;
    slot2 = mod(num, range);
    num = floor(num/range);
    slot1 = mod(num, range);
    num = floor(num/range);
    a = floor((1+sqrt(8*num+1))/2)+1;
    h = num-(a-2)*(a-1)/2;
end