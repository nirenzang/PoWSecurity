global maxForkLen maxDw minDw numOfStates;
minDw = -5;
maxDw = 10;
maxForkLen = 15;
InitStnum;
for i=1:numOfStates
    [a, h, dw, fork, last]=stnum2st(i);
    j=st2stnum(a, h, dw, fork, last);
    if i~=j
        fprintf("i=%d, j=%d\n", i, j);
        break;
    end
end