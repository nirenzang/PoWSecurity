function [a, h, dw, fork, last, matched] = stnum2st(num)
global maxForkLen maxDw minDw;
global tillDwNeg tillDw0 tillDw1 tillDw2 tillDw3;

if num<=tillDwNeg
    % stnum = (a*(maxForkLen+1)+h)*(0-minDw)-dw;
    num = num-1;
	matched = mod(num, 2);
	num = floor(num/2);
    dw = -1-mod(num, (0-minDw));
    num = floor(num/(0-minDw));
    h = mod(num, maxForkLen+1);
    a = floor(num/(maxForkLen+1));
    fork=0; last=0;
elseif num<=tillDw0
    % stnum = tillDwNeg+(a*(maxForkLen+1)+h)*3+fork+1;
    dw = 0;
    num = num-1-tillDwNeg;
	matched = mod(num, 2);
	num = floor(num/2);
    fork = mod(num, 3);
    num = floor(num/3);
    h = mod(num, maxForkLen+1);
    a = floor(num/(maxForkLen+1));
    last = 0;
elseif num<=tillDw1
    % stnum = tillDw0+((a*(maxForkLen+1)+h)*3+fork)*2+mod(last,2)+1;
    dw = 1;
    num =  num-1-tillDw0;
	matched = mod(num, 2);
	num = floor(num/2);
    last = mod(num, 2);
    num = floor(num/2);
    fork = mod(num, 3);
    num = floor(num/3);
    h = mod(num, maxForkLen+1);
    a = floor(num/(maxForkLen+1));
elseif num<=tillDw2
    % stnum = tillDw1+((a*(maxForkLen+1)+h)*3+fork)*4+mod(last,4)+1;
    dw = 2;
    num =  num-1-tillDw1;
	matched = mod(num, 2);
	num = floor(num/2);
    last = mod(num, 4);
    num = floor(num/4);
    fork = mod(num, 3);
    num = floor(num/3);
    h = mod(num, maxForkLen+1);
    a = floor(num/(maxForkLen+1));
elseif num<=tillDw3
    % stnum = tillDw2+((a*(maxForkLen+1)+h)*3+fork)*8+mod(last,8)+1;
    dw = 3;
    num =  num-1-tillDw2;
	matched = mod(num, 2);
	num = floor(num/2);
    last = mod(num, 8);
    num = floor(num/8);
    fork = mod(num, 3);
    num = floor(num/3);
    h = mod(num, maxForkLen+1);
    a = floor(num/(maxForkLen+1));
else % dw>3
    % stnum = tillDw3+((a*(maxForkLen+1)+h)*8+mod(last,8))*(maxDw-3)+(dw-4)+1;
    num = num-tillDw3-1;
	matched = mod(num, 2);
	num = floor(num/2);
    dw = mod(num, maxDw-3)+4;
    num = floor(num/(maxDw-3));
    last = mod(num, 8);
    num = floor(num/8);
    h = mod(num, maxForkLen+1);
    a = floor(num/(maxForkLen+1));
    fork = 0;
end

end