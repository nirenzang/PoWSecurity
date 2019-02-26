global maxForkLen maxhf timeOut
global numOfStates

maxForkLen = 20;
timeOut = 6;
maxhf = 20;
InitStnum;
for i=1:numOfStates
    [ab, hb, hf, fork]=stnum2st(i);
    j=st2stnum(ab, hb, hf, fork);
    if i~=j
        fprintf("i=%d, j=%d\n", i, j);
        break;
    end
end