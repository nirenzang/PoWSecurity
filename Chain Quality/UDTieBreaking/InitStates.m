global maxForkLen alphaPower numOfStates;
global POut RsOut RhOut Wrou;
numOfStates = (maxForkLen*(maxForkLen+1)+maxForkLen)*2+1;
disp(['numOfStates: ' num2str(numOfStates)]);
% a and h can be 0 to maxForkLen, altogether maxForkLen + 1 values
% a=h=0 is invalid
% tie=0: aLose, fork=1: aWin
% actions: 1 adopt, 2 overrideWithTie, 3 overrideWithMore, 4 wait
aLose=0; aWin=1;
choices = 4;
adopt = 1; overrideTie = 2; overrideMore = 3; wait = 4;
baseState = st2stnum(0, 1, aLose);
baseStateS = st2stnum(1, 0, aLose);

% allocate memory
P=cell(1,choices);
AllocateSize=zeros(1, numOfStates*choices);
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
    [a, h, tie] = stnum2st(i);
    P{adopt}.Rh(i) = h;
    P{adopt}.Rh(i+numOfStates) = h;
    % define overrideMore
    if a > h
        P{overrideMore}.Rh(i) = 0;
        P{overrideMore}.P(i) = alphaPower;
        P{overrideMore}.c(i) = st2stnum(a-h, 0, aLose);
        P{overrideMore}.Rs(i) = h+1;
        P{overrideMore}.ii = P{overrideMore}.ii+1;
        P{overrideMore}.r(P{overrideMore}.ii) = i;
        P{overrideMore}.c(P{overrideMore}.ii) = st2stnum(a-h-1, 1, aLose);
        P{overrideMore}.Rs(P{overrideMore}.ii) = h+1;
        if a-h-1 == 0
            P{overrideMore}.P(P{overrideMore}.ii) = 1-alphaPower;
        else
            P{overrideMore}.P(P{overrideMore}.ii) = (1-alphaPower)/2;
            P{overrideMore}.ii = P{overrideMore}.ii+1;
            P{overrideMore}.r(P{overrideMore}.ii) = i;
            P{overrideMore}.c(P{overrideMore}.ii) = st2stnum(a-h-1, 1, aWin);
            P{overrideMore}.P(P{overrideMore}.ii) = (1-alphaPower)/2;
            P{overrideMore}.Rs(P{overrideMore}.ii) = h+1;
        end
    end
    % define overrideTie
    if a >= h && tie == aWin && a-h+1 <= maxForkLen
        P{overrideTie}.Rh(i) = 0;
        P{overrideTie}.P(i) = alphaPower;
        P{overrideTie}.c(i) = st2stnum(a-h+1, 0, aLose);
        P{overrideTie}.Rs(i) = h;
        P{overrideTie}.ii = P{overrideTie}.ii+1;
        P{overrideTie}.r(P{overrideTie}.ii) = i;
        P{overrideTie}.c(P{overrideTie}.ii) = st2stnum(a-h, 1, aLose);
        P{overrideTie}.Rs(P{overrideTie}.ii) = h;
        if a-h == 0
            P{overrideTie}.P(P{overrideTie}.ii) = 1-alphaPower;
        else
            P{overrideTie}.P(P{overrideTie}.ii) = (1-alphaPower)/2;
            P{overrideTie}.ii = P{overrideTie}.ii+1;
            P{overrideTie}.r(P{overrideTie}.ii) = i;
            P{overrideTie}.c(P{overrideTie}.ii) = st2stnum(a-h, 1, aWin);
            P{overrideTie}.P(P{overrideTie}.ii) = (1-alphaPower)/2;
            P{overrideTie}.Rs(P{overrideTie}.ii) = h;
        end
    end
    % define wait
    if a+1 <= maxForkLen && h+1 <= maxForkLen
        if a>h
            % next by a
            P{wait}.Rh(i) = 0;
            P{wait}.c(i) = st2stnum(a+1, h, tie);
            P{wait}.P(i) = alphaPower;
            % next by h
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, aLose);
            P{wait}.P(P{wait}.ii) = (1-alphaPower)/2;
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, aWin);
            P{wait}.P(P{wait}.ii) = (1-alphaPower)/2;
        elseif a==h
            % next by a
            P{wait}.Rh(i) = 0;
            P{wait}.c(i) = st2stnum(a+1, h, tie);
            P{wait}.P(i) = alphaPower;
            % next by h
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, tie);
            P{wait}.P(P{wait}.ii) = 1-alphaPower;
        else % a<h
            % next by a
            P{wait}.Rh(i) = 0;
            P{wait}.c(i) = st2stnum(a+1, h, aLose);
            P{wait}.P(i) = alphaPower/2;
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a+1, h, aWin);
            P{wait}.P(P{wait}.ii) = alphaPower/2;
            % next by h
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, aLose);
            P{wait}.P(P{wait}.ii) = 1-alphaPower;
        end
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