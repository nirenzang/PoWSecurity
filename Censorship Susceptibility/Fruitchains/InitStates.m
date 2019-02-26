global alphaPower gammaRatio bfRatio maxForkLen maxafa maxhf timeOut
global POut RsOut RhOut Wrou
% ab and hb can be 0 to maxForkLen, altogether maxForkLen + 1 values
% last: 0 means hb, 1 means nothb, when last is hb and gamma=1 the attacker can
%     override with a tie
hblast = 1; nothb = 0;
% actions: 1 adopt, 2 override, 3 wait
choices = 3;
adopt = 1; override = 2; wait = 3;
% (ab, hb, hf, fork)
baseStateHb = st2stnum(0, 1, 0, hblast);
baseStateHf = st2stnum(0, 0, 1, nothb);
baseStateAb = st2stnum(1, 0, 0, nothb);
baseStateAf = st2stnum(0, 0, 0, nothb);
Phb = (1-alphaPower)/(1+bfRatio);
Phf = (1-alphaPower)-Phb;
Pab = alphaPower/(1+bfRatio);
Paf = alphaPower-Pab;

% allocate memory
P=cell(1,choices);
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
P{adopt}.c(1:numOfStates) = baseStateHb;
P{adopt}.P(1:numOfStates) = Phb;
P{adopt}.r(numOfStates+1:2*numOfStates) = 1:numOfStates;
P{adopt}.c(numOfStates+1:2*numOfStates) = baseStateHf;
P{adopt}.P(numOfStates+1:2*numOfStates) = Phf;
P{adopt}.r(2*numOfStates+1:3*numOfStates) = 1:numOfStates;
P{adopt}.c(2*numOfStates+1:3*numOfStates) = baseStateAb;
P{adopt}.P(2*numOfStates+1:3*numOfStates) = Pab;
P{adopt}.r(3*numOfStates+1:4*numOfStates) = 1:numOfStates;
P{adopt}.c(3*numOfStates+1:4*numOfStates) = baseStateAf;
P{adopt}.P(3*numOfStates+1:4*numOfStates) = Paf;
P{adopt}.ii = 4*numOfStates;
% define default value for other actions
for i=2:choices
    P{i}.r(1:numOfStates) = 1:numOfStates;
    P{i}.c(1:numOfStates) = baseStateHf;
    P{i}.P(1:numOfStates) = 1;
    P{i}.Rh(1:numOfStates) = 10000;
    P{i}.ii = numOfStates;
end

for i = 1:numOfStates
    if mod(i, 10000)==0
        disp(['processing state: ' num2str(i)]);
    end
    [ab, hb, hf, last] = stnum2st(i);
    P{adopt}.Rh(i:numOfStates:3*numOfStates+i) = hf;
    % define override
    if gammaRatio==1 && last==hblast
        published = hb;
    else
        published = hb+1;
    end
    % limitation: override always publishes everything!
    if ab>=published % we can override
        P{override}.Rh(i) = 0;
        P{override}.P(i) = Phb;
        P{override}.c(i) = baseStateHb;
        if ab>=timeOut
            P{override}.Rh(i) = 0;
            P{override}.Rs(i) = hf;
        else
            P{override}.Rh(i) = hf;
        end
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = baseStateHf;
        P{override}.P(P{override}.ii) = Phf;
        P{override}.Rs(P{override}.ii) = P{override}.Rs(i);
        P{override}.Rh(P{override}.ii) = P{override}.Rh(i);
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = baseStateAb;
        P{override}.P(P{override}.ii) = Pab;
        P{override}.Rs(P{override}.ii) = P{override}.Rs(i);
        P{override}.Rh(P{override}.ii) = P{override}.Rh(i);
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = baseStateAf;
        P{override}.P(P{override}.ii) = Paf;
        P{override}.Rs(P{override}.ii) = P{override}.Rs(i);
        P{override}.Rh(P{override}.ii) = P{override}.Rh(i);
    end
    % define wait
    if max(ab+1, hb+1)<=maxForkLen && hf<maxhf
        P{wait}.P(i) = Phb;
        P{wait}.c(i) = st2stnum(ab, hb+1, hf, hblast);
        P{wait}.Rh(i) = 0;
        P{wait}.ii = P{wait}.ii+1;
        P{wait}.r(P{wait}.ii) = i;
        P{wait}.c(P{wait}.ii) = st2stnum(ab, hb, hf+1, nothb);
        P{wait}.P(P{wait}.ii) = Phf;
        P{wait}.ii = P{wait}.ii+1;
        P{wait}.r(P{wait}.ii) = i;
        P{wait}.c(P{wait}.ii) = st2stnum(ab+1, hb, hf, nothb);
        P{wait}.P(P{wait}.ii) = Pab;
        P{wait}.ii = P{wait}.ii+1;
        P{wait}.r(P{wait}.ii) = i;
        P{wait}.P(P{wait}.ii) = Paf;
        if ab<timeOut
            P{wait}.c(P{wait}.ii) = st2stnum(ab, hb, hf, nothb);
        else
            P{wait}.c(P{wait}.ii) = st2stnum(ab, hb, hf, nothb);
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
