global numOfStates;
for i=1:numOfStates
    [a, h, fork] = stnum2st(i);
    if a>h+2 && h>0 && (lowerBoundPolicy(i)==2 || lowerBoundPolicy(i)==3)
        fprintf("i=%d, optimal policy: %d\n", i, lowerBoundPolicy(i));
        break;
    end
end