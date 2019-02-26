function stnum = st2stnum(a, h, fork, history)
global maxForkLen maxHistoryPlus1;
global tillaSmaller;
% fork: 0 means irrelevant, 1 means relevant, 2 means active
assert(a<=maxForkLen && h<=maxForkLen);
assert(history<maxHistoryPlus1);
assert(fork<3);
% tillaSmaller = (1+maxForkLen)*maxForkLen/2*maxHistoryPlus1;
if a<h
    stnum = (h*(h-1)/2+a)*maxHistoryPlus1+history+1;
% numOfStates = tillaSmaller+maxForkLen*(maxForkLen+3)/2*3*maxHistoryPlus1;
else
    stnum = tillaSmaller+(((a+2)*(a-1)/2+h)*3+fork)*maxHistoryPlus1+history+1;
end

