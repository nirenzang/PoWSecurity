global maxForkLen maxafa maxhf timeOut
global numOfStates

maxForkLen = 20;
maxafa = 10;
timeOut = 6;
maxhf = 20;
InitStnum;
for i=1:numOfStates
    [ab, hb, afA, hf, fork]=stnum2st(i);
    j=st2stnum(ab, hb, afA, hf, fork);
    if i~=j
        fprintf("i=%d, j=%d\n", i, j);
        break;
    end
end