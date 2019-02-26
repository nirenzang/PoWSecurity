global maxForkLen maxHistoryLen numOfStates

maxForkLen = 20;
maxHistoryLen = 7;
InitStnum;
for i=1:numOfStates
    [a, h, fork, history]=stnum2st(i);
    j=st2stnum(a, h, fork, history);
    if i~=j
        fprintf("i=%d, j=%d\n", i, j);
        break;
    end
end