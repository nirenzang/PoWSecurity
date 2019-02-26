global maxForkLen alphaPower gammaRatio numOfStates;
global POut RsOut RhOut Wrou;
numOfStates = (maxForkLen*(maxForkLen+1)+maxForkLen)*2+1;
disp(['numOfStates: ' num2str(numOfStates)]);
% a and h can be 0 to maxForkLen, altogether maxForkLen + 1 values
% a=h=0 is invalid
% fork=0: inactive, fork=1: active; active means during a tie
% actions: 1 adopt, 2 override, 3 match, 4 wait
inactive=0; active=1;
choices = 4;
adopt = 1; override = 2; match = 3; wait = 4;
baseState = st2stnum(0, 1, inactive);
baseStateS = st2stnum(1, 0, inactive);

% allocate memory
P=cell(1,5);
AllocateSize=zeros(1, numOfStates*5);
for i=1:choices
    % r is the row # in transition matrix
    P{i}.r = AllocateSize;
    % c is the column # in transition matrix
    P{i}.c = AllocateSize;
    % P is the transition probability
    P{i}.P = AllocateSize;
    % Rs is the reward for selfish miner
    P{i}.Rs = AllocateSize;
    % Rh is the reward for honest miners
    P{i}.Rh = AllocateSize;
    P{i}.ii = 0;
end

% define adopt
P{adopt}.r(1:numOfStates) = 1:numOfStates;
P{adopt}.c(1:numOfStates) = baseState;
P{adopt}.P(1:numOfStates) = 1-alphaPower;
P{adopt}.r(numOfStates+1:2*numOfStates) = 1:numOfStates;
P{adopt}.c(numOfStates+1:2*numOfStates) = baseStateS;
P{adopt}.P(numOfStates+1:2*numOfStates) = alphaPower;
P{adopt}.ii = 2*numOfStates;
% define default value for other actions
for i=2:choices
    P{i}.r(1:numOfStates) = 1:numOfStates;
    P{i}.c(1:numOfStates) = baseState;
    P{i}.P(1:numOfStates) = 1;
    P{i}.Rh(1:numOfStates) = 10000;
    P{i}.ii = numOfStates;
end

for i = 1:numOfStates
    if mod(i, 2000)==0
        disp(['processing state: ' num2str(i)]);
    end
    [a, h, fork] = stnum2st(i);
    P{adopt}.Rh(i) = h;
    P{adopt}.Rh(i+numOfStates) = h;
    % define override
    if a > h
        P{override}.Rh(i) = 0;
        P{override}.P(i) = alphaPower;
        P{override}.c(i) = st2stnum(a-h, 0, inactive);
        P{override}.Rs(i) = h+1;
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = st2stnum(a-h-1, 1, inactive);
        P{override}.P(P{override}.ii) = 1-alphaPower;
        P{override}.Rs(P{override}.ii) = h+1;
    end
    % define wait
    if fork ~= active && a+1 <= maxForkLen && h+1 <= maxForkLen
        P{wait}.Rh(i) = 0;
        P{wait}.c(i) = st2stnum(a+1, h, inactive);
        P{wait}.P(i) = alphaPower;
        P{wait}.ii = P{wait}.ii+1;
        P{wait}.r(P{wait}.ii) = i;
        P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, inactive);
        P{wait}.P(P{wait}.ii) = 1-alphaPower;
    elseif fork == active && a > h && h > 0 && a+1 <= maxForkLen && h+1 <= maxForkLen
        P{wait}.Rh(i) = 0;
        P{wait}.c(i) = st2stnum(a+1, h, active);
        P{wait}.P(i) = alphaPower;
        P{wait}.ii = P{wait}.ii+1;
        P{wait}.r(P{wait}.ii) = i;
        P{wait}.c(P{wait}.ii) = st2stnum(a-h, 1, inactive);
        P{wait}.P(P{wait}.ii) = gammaRatio*(1-alphaPower);
        P{wait}.Rs(P{wait}.ii) = h;
        P{wait}.ii = P{wait}.ii+1;
        P{wait}.r(P{wait}.ii) = i;
        P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, inactive);
        P{wait}.P(P{wait}.ii) = (1-gammaRatio)*(1-alphaPower);
    end
    % define match: match if feasible when the selfish chain is no shorter
    % than honest chain
    if a >= h && h > 0 && a+1 <= maxForkLen && h+1 <= maxForkLen
        P{match}.Rh(i) = 0;
        P{match}.c(i) = st2stnum(a+1, h, active);
        P{match}.P(i) = alphaPower;
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(a-h, 1, inactive);
        P{match}.P(P{match}.ii) = gammaRatio*(1-alphaPower);
        P{match}.Rs(P{match}.ii) = h;
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(a, h+1, inactive);
        P{match}.P(P{match}.ii) = (1-gammaRatio)*(1-alphaPower);
    end
end

POut = cell(1,choices);
% Rs is the reward for selfish miner
RsOut = cell(1,choices);
% Rh is the reward for honest miners
RhOut = cell(1,choices);
Wrou = cell(1,choices);
for i=1:choices
    Wrou{i} = sparse(numOfStates, numOfStates);
    P{i}.r(P{i}.ii+1:end)=[];
    P{i}.c(P{i}.ii+1:end)=[];
    P{i}.P(P{i}.ii+1:end)=[];
    P{i}.Rh(P{i}.ii+1:end)=[];
    P{i}.Rs(P{i}.ii+1:end)=[];
    POut{i}=sparse(P{i}.r, P{i}.c, P{i}.P);
    RhOut{i}=sparse(P{i}.r, P{i}.c, P{i}.Rh);
    RsOut{i}=sparse(P{i}.r, P{i}.c, P{i}.Rs);
    [m, n]=size(POut{i});
    if n ~= numOfStates
        POut{i}(numOfStates, numOfStates) = 0;
        RsOut{i}(numOfStates, numOfStates) = 0;
        RhOut{i}(numOfStates, numOfStates) = 0;
    end
end