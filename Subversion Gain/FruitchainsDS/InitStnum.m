global maxForkLen maxafa maxhf timeOut
global maxGroup numOfStates

% group encompasses ab and afA
maxGroup = timeOut-1+(maxForkLen-timeOut)*(1+maxafa)+maxafa+1;
numOfStates = (maxGroup+1)*(maxForkLen+1)*(maxhf+1)*2;
disp(['numOfStates: ' num2str(numOfStates)]);