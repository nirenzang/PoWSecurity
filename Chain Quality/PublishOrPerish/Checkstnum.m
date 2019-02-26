clear

global alphaPower m;
global maxB numOfStates;
maxB = 10;
alphaPower = 0.4;

more = maxB+1;
numOfStates=((((maxB*more+maxB)*more+maxB)*2+1)*2+1)*more+maxB;
disp(['numOfStates: ' num2str(numOfStates)]);
choices = 5;
adopt = 1; override = 2; match = 3; even = 4; hide = 5;

P = cell(1,choices);
% Rs is the reward for selfish miner
Rs = cell(1,choices);
% Rh is the reward for honest miners
Rh = cell(1,choices);
Wrou = cell(1,choices);
for i = 1:5
    P{i} = sparse(numOfStates, numOfStates);
    Rs{i} = sparse(numOfStates, numOfStates);
    Rh{i} = sparse(numOfStates, numOfStates);
    Wrou{i} = sparse(numOfStates, numOfStates);
end

for i = 1:numOfStates
    if mod(i, 10000)==0
        disp(i);
    end
    [Bh, Bs, Dw, luck, last, published] = stnum2st(i);
    j = st2stnum(Bh, Bs, Dw, luck, last, published);
    if i~=j
        disp(['i=' num2str(i)]);
    end
end