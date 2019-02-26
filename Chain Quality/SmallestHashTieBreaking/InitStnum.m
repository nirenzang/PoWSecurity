global maxForkLen range;
global tillaSmaller tillaEqual tillaOneBigger numOfStates;
% smaller: a<h, remember h (1 to maxForkLen), a (0 to h-1), htop (0 to range-1)
tillaSmaller = (1+maxForkLen)*maxForkLen/2*range;
fprintf("tillaSmaller: %d\n", tillaSmaller);
% equal: a=h>0 (1 to maxForkLen)
tillaEqual = tillaSmaller+maxForkLen*2;
% in this range: "-1" "mod 2" = tie; "+1" "/2" = a
fprintf("tillaEqual: %d\n", tillaEqual);
% oneBigger: a=h+1, a to 1 to maxForkLen
tillaOneBigger = tillaEqual+maxForkLen*2*range;
fprintf("tillaOneBigger: %d\n", tillaOneBigger);
% tillaBigger: a>h+1, a (2 to maxForkLen), h(0 to maxForkLen-2), atop1 (0
% to range-1), atop2
numOfStates = tillaOneBigger+maxForkLen*(maxForkLen-1)/2*range*range;
fprintf("numOfStates (tillaBigger): %d\n", numOfStates);