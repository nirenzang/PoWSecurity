global alphaPower gammaRatio maxForkLen timeOut numOfStates;
global POut RsOut RhOut Wrou;
% a and h can be 0 to maxForkLen, altogether maxForkLen + 1 values
% fork: 0 means irrelevant: match is not feasible, either last block is
% selfish OR honest branch is empty
% 1 means relevant: if a>=h now, match is feasible, e.g. last block is honest
% 2 means active (just perfomed a match)
global irrelevant relevant active; 
irrelevant = 0; relevant = 1; active = 2;
choices = 3+timeOut-1; % allow override from 1 to timeOut-1
adopt = 1; wait = 2; match = 3; override = 4;
baseStateH = st2stnum(0, 1, irrelevant, 0);
baseStateS = st2stnum(1, 0, irrelevant, 0);

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
P{adopt}.c(1:numOfStates) = baseStateH;
P{adopt}.P(1:numOfStates) = 1-alphaPower;
P{adopt}.r(numOfStates+1:2*numOfStates) = 1:numOfStates;
P{adopt}.c(numOfStates+1:2*numOfStates) = baseStateS;
P{adopt}.P(numOfStates+1:2*numOfStates) = alphaPower;
P{adopt}.ii = 2*numOfStates;
% define default value for other actions
for i=2:choices
    P{i}.r(1:numOfStates) = 1:numOfStates;
    P{i}.c(1:numOfStates) = baseStateH;
    P{i}.P(1:numOfStates) = 1;
    P{i}.Rh(1:numOfStates) = 10000;
    P{i}.ii = numOfStates;
end

for i = 1:numOfStates
    if mod(i, 10000)==0
        disp(['processing state: ' num2str(i)]);
    end
    [a, h, fork, history] = stnum2st(i);
    temp = history;
    if history==0
        historyLen = 0;
    else
        historyLen = floor(log2(history)+1);
    end
    historySum = countBlocks(history);
    P{adopt}.Rh(i) = abs(h-a)+(historySum+a)/2;
    P{adopt}.Rs(i) = (historySum+a)/2;
    P{adopt}.Rh(i+numOfStates) = abs(h-a)+(historySum+a)/2;
    P{adopt}.Rs(i+numOfStates) = (historySum+a)/2;
    % define override
	for override=4:choices
	    margin = override-3;
        if a >= h+margin && a-(h+margin)+1<=maxForkLen
            if h+margin>=timeOut-1 % history is cleared
            % history only remembers timeOut-1 blocks, and in override, the last one
            %     is "0", namely only selfish block
                % next by a
                P{override}.P(i) = alphaPower;
                P{override}.Rh(i) = 0;
                % h+margin: all attakcer blocks that are published; timeOut-1-margin:
                %   remaining honest blocks in history
                % P{override}.Rs(i) = historySum+(h+margin-(timeOut-1-margin));
                P{override}.Rs(i) = historySum+(h+margin-(timeOut-1));
                newHistory = 2^(timeOut-1)-2^margin;
                P{override}.c(i) = st2stnum(a-h-margin+1, 0, irrelevant, newHistory);
                % next by h
                P{override}.ii = P{override}.ii+1;
                P{override}.r(P{override}.ii) = i;
                P{override}.c(P{override}.ii) = st2stnum(a-h-margin, 1, relevant, newHistory);
                P{override}.P(P{override}.ii) = 1-alphaPower;
                % P{override}.Rs(P{override}.ii) = historySum+(h+margin-(timeOut-1-margin));
                P{override}.Rs(P{override}.ii) = historySum+(h+margin-(timeOut-1));
            else % preserve part of history
                % timeOut-1: new history length, h+margin, current race that goes
                %     into the new history
                preservedHistoryLen = (timeOut-1)-(h+margin);
                preservedHistory = bitand(history,(2^preservedHistoryLen-1)); % latest bits of history remains
                % compute how much rewards are settled for the attacker
                settledBlocks = countBlocks(history-preservedHistory);
                newHistory = preservedHistory*2^(h+margin)+2^(h+margin)-2^margin;
                % next by a
                P{override}.P(i) = alphaPower;
                P{override}.Rh(i) = 0;
                % P{override}.Rs(i) = settledBlocks+margin; % +margin is the last published attacker blocks
                P{override}.Rs(i) = settledBlocks; % +margin is the last published attacker blocks
                P{override}.c(i) = st2stnum(a-(h+margin)+1, 0, irrelevant, newHistory);
                % next by h
                P{override}.ii = P{override}.ii+1;
                P{override}.r(P{override}.ii) = i;
                P{override}.c(P{override}.ii) = st2stnum(a-(h+margin), 1, relevant, newHistory);
                P{override}.P(P{override}.ii) = 1-alphaPower;
                % P{override}.Rs(P{override}.ii) = settledBlocks+margin;
                P{override}.Rs(P{override}.ii) = settledBlocks;
            end
        end
	end
    % define wait
    if fork ~= active && a+1 <= maxForkLen && h+1 <= maxForkLen
        P{wait}.Rh(i) = 0;
        P{wait}.c(i) = st2stnum(a+1, h, irrelevant, history);
        P{wait}.P(i) = alphaPower;
        P{wait}.ii = P{wait}.ii+1;
        P{wait}.r(P{wait}.ii) = i;
        P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, relevant, history);
        P{wait}.P(P{wait}.ii) = 1-alphaPower;
    elseif fork == active && a >= h && h > 0 && a+1 <= maxForkLen && h+1 <= maxForkLen
        % next by a
        P{wait}.Rh(i) = 0;
        P{wait}.c(i) = st2stnum(a+1, h, active, history);
        P{wait}.P(i) = alphaPower;
        % next by h on h
        P{wait}.ii = P{wait}.ii+1;
        P{wait}.r(P{wait}.ii) = i;
        P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, relevant, history);
        P{wait}.P(P{wait}.ii) = (1-gammaRatio)*(1-alphaPower);
        % next by h on a
        P{wait}.ii = P{wait}.ii+1;
        P{wait}.r(P{wait}.ii) = i;
        P{wait}.P(P{wait}.ii) = gammaRatio*(1-alphaPower);
		fullHistory = history*2^h+2^h-1;
        newHistory = mod(fullHistory, 2^(timeOut-1));
        aReward=countBlocks(fullHistory-newHistory);
        P{wait}.c(P{wait}.ii) = st2stnum(a-h, 1, relevant, newHistory);
        P{wait}.Rs(P{wait}.ii) = aReward;
    end
    % define match: match if feasible only when the last block is honest
    % and the selfish miner has more blocks before the last block is mined
    if fork == relevant && a >= h && h > 0 && a+1 <= maxForkLen && h+1 <= maxForkLen
        % next by a
        P{match}.Rh(i) = 0;
        P{match}.c(i) = st2stnum(a+1, h, active, history);
        P{match}.P(i) = alphaPower;
        % next by h on h
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(a, h+1, relevant, history);
        P{match}.P(P{match}.ii) = (1-gammaRatio)*(1-alphaPower);
        % next by h on a
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.P(P{match}.ii) = gammaRatio*(1-alphaPower);
        fullHistory = history*2^h+2^h-1;
        newHistory = mod(fullHistory, 2^(timeOut-1));
        aReward=countBlocks(fullHistory-newHistory);
        P{match}.c(P{match}.ii) = st2stnum(a-h, 1, relevant, newHistory);
        P{match}.Rs(P{match}.ii) = aReward;
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
