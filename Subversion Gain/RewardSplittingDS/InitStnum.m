global maxForkLen
global tillaSmaller numOfStates maxHistoryPlus1

maxHistoryPlus1 = 2^maxHistoryLen;
% history range from 0 to 2^maxHistoryLen-1, total 2^maxHistoryLen values
% tillaSmaller: a < h, a (0 to h-1), h (1 to maxForkLen), history
tillaSmaller = (1+maxForkLen)*maxForkLen/2*maxHistoryPlus1*2;
% other: a>=h, remember a, h, fork, history
fprintf("tillaSmaller: %d\n", tillaSmaller);
numOfStates = tillaSmaller+maxForkLen*(maxForkLen+3)/2*3*maxHistoryPlus1*2;
fprintf("numOfStates: %d\n", numOfStates);