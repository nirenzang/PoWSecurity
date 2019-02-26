global alphaPower gammaRatio maxForkLen maxDw minDw numOfStates mtimes;
global POut RsOut RhOut Wrou;
% a and h can be 0 to maxForkLen, altogether maxForkLen + 1 values
% fork: 0 means irrelevant: match is not feasible, either last block is
% selfish OR honest branch is empty
% 1 means relevant: if a>=h>0 now, match is feasible, e.g. last block is honest
% 2 means active (just perfomed a match)
global irrelevant relevant active; 
irrelevant = 0; relevant = 1; active = 2;
% actions: 1 adopt, 2 override, 3 match, 4 wait
choices = 4;
adopt = 1; override = 2; match = 3; wait = 4;
baseStateHb = st2stnum(0, 1, -1, irrelevant, 0);
baseStateHi = st2stnum(0, 0, -1, irrelevant, 0);
baseStateAb = st2stnum(1, 0, 1, irrelevant, 0);
baseStateAi = st2stnum(0, 0, 1, irrelevant, 0);
Phb = (1-alphaPower)/mtimes;
Phi = (1-alphaPower)*(mtimes-1)/mtimes;
Pab = alphaPower/mtimes;
Pai = alphaPower*(mtimes-1)/mtimes;

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
P{adopt}.c(1:numOfStates) = baseStateHb;
P{adopt}.P(1:numOfStates) = Phb;
P{adopt}.r(numOfStates+1:2*numOfStates) = 1:numOfStates;
P{adopt}.c(numOfStates+1:2*numOfStates) = baseStateHi;
P{adopt}.P(numOfStates+1:2*numOfStates) = Phi;
P{adopt}.r(2*numOfStates+1:3*numOfStates) = 1:numOfStates;
P{adopt}.c(2*numOfStates+1:3*numOfStates) = baseStateAb;
P{adopt}.P(2*numOfStates+1:3*numOfStates) = Pab;
P{adopt}.r(3*numOfStates+1:4*numOfStates) = 1:numOfStates;
P{adopt}.c(3*numOfStates+1:4*numOfStates) = baseStateAi;
P{adopt}.P(3*numOfStates+1:4*numOfStates) = Pai;
P{adopt}.ii = 4*numOfStates;
% define default value for other actions
for i=2:choices
    P{i}.r(1:numOfStates) = 1:numOfStates;
    P{i}.c(1:numOfStates) = baseStateHb;
    P{i}.P(1:numOfStates) = 1;
    P{i}.Rh(1:numOfStates) = 10000;
    P{i}.ii = numOfStates;
end

for i = 1:numOfStates
    if mod(i, 10000)==0
        disp(['processing state: ' num2str(i)]);
    end
    % last: 0 means inblock, 1 means block, the last digit (mod2) is the
    %     tip of the chain
    [a, h, dw, fork, last] = stnum2st(i);
    P{adopt}.Rh(i:numOfStates:3*numOfStates+i) = h;
    blocksInLast = floor(last/4)+floor(mod(last,4)/2)+mod(last,2);
    if a<blocksInLast
        continue;
    end
    % define override
    if dw>0
        % limitation: inaccurate when override with lead>4: when lead>4, always
        %     publish everything except the last three
        lastLenLeft = min(3, dw-1);
        newLast = mod(last, 2^lastLenLeft);
        aLeft = floor(newLast/4)+floor(mod(newLast,4)/2)+mod(newLast,2);
        % next is honest block
        P{override}.Rh(i) = 0;
        % new last will be truncated according to the new dw in the
        %     st2stnum function; if the new dw<0, fork will be ignored
        P{override}.c(i) = st2stnum(aLeft, 1, lastLenLeft-1, relevant, newLast);
        P{override}.P(i) = Phb;
        P{override}.Rs(i) = a-aLeft;
        % next is honest inblock
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = st2stnum(aLeft, 0, lastLenLeft-1, relevant, newLast);
        P{override}.P(P{override}.ii) = Phi;
        P{override}.Rs(P{override}.ii) = a-aLeft;
        % next is selfish block
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = st2stnum(aLeft+1, 0, lastLenLeft+1, irrelevant, newLast*2+1);
        P{override}.P(P{override}.ii) = Pab;
        P{override}.Rs(P{override}.ii) = a-aLeft;
        % next is selfish inblock
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = st2stnum(aLeft, 0, lastLenLeft+1, irrelevant, newLast*2);
        P{override}.P(P{override}.ii) = Pai;
        P{override}.Rs(P{override}.ii) = a-aLeft;
    end
    
    % define wait
    if a < maxForkLen && h < maxForkLen && dw<maxDw && dw>minDw
        if fork ~= active
            % next is honest block
            P{wait}.Rh(i) = 0;
            P{wait}.c(i) = st2stnum(a, h+1, dw-1, relevant, last);
            P{wait}.P(i) = Phb;
            % next is honest inblock
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a, h, dw-1, relevant, last);
            P{wait}.P(P{wait}.ii) = Phi;
            % next is selfish block
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a+1, h, dw+1, irrelevant, last*2+1);
            P{wait}.P(P{wait}.ii) = Pab;
            % next is selfish inblock
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a, h, dw+1, irrelevant, last*2);
            P{wait}.P(P{wait}.ii) = Pai;
        % limitation: if dw>3, lost track of how many blocks are in the 
        %     lead of the selfish chain
        % in stnum2st, fork is only meaningful when dw=0 to 3
        elseif fork == active
            % honest block on honest chain
            P{wait}.Rh(i) = 0;
            P{wait}.c(i) = st2stnum(a, h+1, dw-1, relevant, last);
            P{wait}.P(i) = Phb*(1-gammaRatio);
            % honest inblock on honest chain
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a, h, dw-1, relevant, last);
            P{wait}.P(P{wait}.ii) = Phi*(1-gammaRatio);
            % honest block on selfish chain
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(blocksInLast, 1, dw-1, relevant, last);
            P{wait}.P(P{wait}.ii) = Phb*gammaRatio;
			P{wait}.Rs(P{wait}.ii) = a-blocksInLast;
            % honest inblock on selfish chain
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(blocksInLast, 0, dw-1, relevant, last);
            P{wait}.P(P{wait}.ii) = Phi*gammaRatio;
			P{wait}.Rs(P{wait}.ii) = a-blocksInLast;
            % selfish block on selfish chain
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a+1, h, dw+1, active, last*2+1);
            P{wait}.P(P{wait}.ii) = Pab;
            % selfish inblock on selfish chain
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a, h, dw+1, active, last*2);
            P{wait}.P(P{wait}.ii) = Pai;
        end
    end
    % define match: match if feasible only when the last block is honest
    %     and dw=0 to 3
    if fork == relevant && dw>=0 && dw<=3 && a+1 <= maxForkLen && h+1 <= maxForkLen
        % honest block on honest chain
        P{match}.Rh(i) = 0;
        P{match}.c(i) = st2stnum(a, h+1, dw-1, relevant, last);
        P{match}.P(i) = Phb*(1-gammaRatio);
        % honest inblock on honest chain
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(a, h, dw-1, relevant, last);
        P{match}.P(P{match}.ii) = Phi*(1-gammaRatio);
        % honest block on selfish chain
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(blocksInLast, 1, dw-1, relevant, last);
        P{match}.P(P{match}.ii) = Phb*gammaRatio;
		P{match}.Rs(P{match}.ii) = a-blocksInLast;
        % honest inblock on selfish chain
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(blocksInLast, 0, dw-1, relevant, last);
        P{match}.P(P{match}.ii) = Phi*gammaRatio;
		P{match}.Rs(P{match}.ii) = a-blocksInLast;
        % selfish block on selfish chain
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(a+1, h, dw+1, active, last*2+1);
        P{match}.P(P{match}.ii) = Pab;
        % selfish inblock on selfish chain
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(a, h, dw+1, active, last*2);
        P{match}.P(P{match}.ii) = Pai;
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
