global maxForkLen numOfStates

maxForkLen = 20;
numOfStates = (maxForkLen+1)*(maxForkLen+1)*3*2;
disp(['numOfStates: ' num2str(numOfStates)]);
for i=1:numOfStates
    [a, h, fork, matchedBeforeCfn]=stnum2st(i);
    j=st2stnum(a, h, fork, matchedBeforeCfn);
    if i~=j
        fprintf("i=%d, j=%d\n", i, j);
        break;
    end
end