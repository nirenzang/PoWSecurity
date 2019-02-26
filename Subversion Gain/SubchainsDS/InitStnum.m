global maxForkLen maxDw minDw;
global tillDwNeg tillDw0 tillDw1 tillDw2 tillDw3 numOfStates;
% tillDwNeg: minDw<=Dw<0, remember a, h (both 0 to maxForkLen), dw
tillDwNeg = (1+maxForkLen)*(1+maxForkLen)*(0-minDw)*2;
fprintf("tillDwNeg: %d\n", tillDwNeg);
% tillDw0: dw=0, remember a, h, fork 
tillDw0 = tillDwNeg+(1+maxForkLen)*(1+maxForkLen)*3*2;
fprintf("tillDw0: %d\n", tillDw0);
% tillDw1: dw=1, remember a, h, fork, last (0 or 1)
tillDw1 = tillDw0+(1+maxForkLen)*(1+maxForkLen)*3*2*2;
fprintf("tillDw1: %d\n", tillDw1);
% tillDw2: dw=2, remember a, h, fork, last (0 to 3)
tillDw2 = tillDw1+(1+maxForkLen)*(1+maxForkLen)*3*4*2;
fprintf("tillDw2: %d\n", tillDw2);
% tillDw3: dw=3, remember a, h, fork, last (0 to 7)
tillDw3 = tillDw2+(1+maxForkLen)*(1+maxForkLen)*3*8*2;
fprintf("tillDw3: %d\n", tillDw3);
% numOfStates: new part dw>3, remember a, h, dw, last (0 to 7)
numOfStates = tillDw3+(1+maxForkLen)*(1+maxForkLen)*(maxDw-4+1)*8*2;
fprintf("numOfStates (till dw is more than 3): %d\n", numOfStates);