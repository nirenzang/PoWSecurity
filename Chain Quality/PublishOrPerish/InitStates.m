global alphaPower maxB superOverride POut RsOut RhOut maxBmore;

maxBmore = maxB+1;
numOfStates=((((maxB*maxBmore+maxB)*maxBmore+maxB)*2+1)*2+1)*maxBmore+maxB;
disp('numOfStates: ');
disp(numOfStates);
choices = 5;
adopt = 1; override = 2; match = 3; even = 4; hide = 5;
lastH = 0; lastS = 1;
Psb = alphaPower;
Phb = 1-alphaPower;
baseState = st2stnum(1, 0, 1, 0, lastH, 0);
baseStateS = st2stnum(0, 1, 0, 0, lastS, 0);

% allocate memory
P=cell(1,5);
AllocateSize=zeros(1, numOfStates*5);
for i=1:choices
    P{i}.r = AllocateSize;
    P{i}.c = AllocateSize;
    P{i}.P = AllocateSize;
    P{i}.Rs = AllocateSize;
    P{i}.Rh = AllocateSize;
    P{i}.ii = 0;
end

P{adopt}.r(1:numOfStates) = 1:numOfStates;
P{adopt}.c(1:numOfStates) = baseState;
P{adopt}.P(1:numOfStates) = Phb;
P{adopt}.r(numOfStates+1:2*numOfStates) = 1:numOfStates;
P{adopt}.c(numOfStates+1:2*numOfStates) = baseStateS;
P{adopt}.P(numOfStates+1:2*numOfStates) = Psb;
P{adopt}.ii = 2*numOfStates;
for i=2:choices
    P{i}.r(1:numOfStates) = 1:numOfStates;
    P{i}.c(1:numOfStates) = baseState;
    P{i}.P(1:numOfStates) = 1;
    P{i}.Rh(1:numOfStates) = 10000;
    P{i}.ii = numOfStates;
end

for i = 1:numOfStates
    if mod(i, 50000)==0
        disp(['processing state: ' num2str(i)]);
    end
    [Bh, Bs, Dw, luck, last, published] = stnum2st(i);
    P{adopt}.Rh(i) = Bh;
    P{adopt}.Rh(i+numOfStates) = Bh;
    
    % illegal states, force adoption
    % always decide whether to publish the latest selfish block at the
    %     beginning of the next step!
    % ensure that if lucky == 1, Bh>0, Bs>=Bh and when lastS, Bs>Bh
    if published > Bs-last || Dw > Bh+1 || last == lastH && Bh == 0 ...
            || last == lastS && Bs == 0 || (luck == 1 && (Bh == 0 || Bs < Bh ...
            || Bs == Bh && last == lastS))
        continue;
    end
    
    % luckyOne: the selfish miner earns two points in weight by publishing this one
    % newLuckHnext: if the next block is honest, whether luck remains 1
    luckyOne = -1; newLuckHnext = 0;
    if luck == 1
        if last == lastH
            luckyOne = Bh;
        else
            luckyOne = Bh+1;
            newLuckHnext = 1;
        end
    end
    % newLuckSnext: if the next block is selfish, whether it could be a lucky
    %     one
    if Bs == Bh && Bh > 0
        newLuckSnext = 1;
    else
        newLuckSnext = 0;
    end
    % calculate if the selfish miner publishes everything, the minDw
    % next: the next selfish block that can earn weight
    next = published+1;
    if next < Bh && last == lastH
        next = Bh;
    elseif next < Bh+1 && last == lastS
        next = Bh+1;
    end
    if Bs < next % nothing to publish
        minDw = Dw;
    else
        minDw = Dw-(Bs-next+1+luck);
    end
    
    % define override
    if minDw < 0 || Bs-Bh >= superOverride
        P{override}.P(i) = 0;
        P{override}.Rh(i) = 0;
        publishUntil = Bs+minDw+1;
		if publishUntil-Bh > superOverride
		    publishUntil = Bh+superOverride;
		end
        % impossible to override without publishing the lucky one
        if publishUntil < luckyOne
            publishUntil = luckyOne;
        end
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = st2stnum(0, Bs-publishUntil+1, 0, 0, lastS, 0);
        P{override}.P(P{override}.ii) = Psb;
        P{override}.Rs(P{override}.ii) = publishUntil;
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = st2stnum(1, Bs-publishUntil, 1, 0, lastH, 0);
        P{override}.P(P{override}.ii) = Phb;
        P{override}.Rs(P{override}.ii) = publishUntil;
    end
    
    if minDw <= 0
        matchPublishUntil = Bs+minDw;
        if matchPublishUntil == Bh-1 && luckyOne == Bh+1
            matchPublishUntil = Bh;
        elseif luck == 1 && matchPublishUntil == luckyOne-1
            matchPublishUntil = -1;
        end
    else
        matchPublishUntil = -1;
    end

    % define match: make two chains the same weight or at least try
    if matchPublishUntil ~= -1 && Bs < maxB && Bh < maxB
        P{match}.P(i) = 0;
        P{match}.Rh(i) = 0;
        % honestLuck: if the Bh-th selfish block is published, the new honest
        %     block would earn two points
        if matchPublishUntil >= Bh && Bh > 0
            honestLuck = 2;
        else
            honestLuck = 1;
        end
        % my block on my branch
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.P(P{match}.ii) = Psb;
        if luckyOne == Bh+1 && matchPublishUntil == Bh % preserve the secret luckyOne
            P{match}.c(P{match}.ii) = st2stnum(Bh, Bs+1, 0, 1, lastS, matchPublishUntil);
        else
            P{match}.c(P{match}.ii) = st2stnum(Bh, Bs+1, 0, newLuckSnext, lastS, matchPublishUntil);
        end
        % honest block on honest branch
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(Bh+1, Bs, honestLuck, newLuckHnext, lastH, matchPublishUntil);
        P{match}.P(P{match}.ii) = Phb*0.5;
        % honest block on my branch
        if Bs > matchPublishUntil
            tempC = st2stnum(1, Bs-matchPublishUntil, honestLuck, 0, lastH, 0);
        else % the next selfish block can still be lucky, no point to introduce "honestLuck"
            tempC = st2stnum(1, 0, 1, 0, lastH, 0);
        end
        if P{match}.c(P{match}.ii) == tempC && P{match}.r(P{match}.ii) == i
            P{match}.P(P{match}.ii) = P{match}.P(P{match}.ii)+ Phb*0.5;
            P{match}.Rs(P{match}.ii) = matchPublishUntil;
        elseif P{match}.c(P{match}.ii-1) == tempC && P{match}.r(P{match}.ii-1) == i
            P{match}.P(P{match}.ii-1) = P{match}.P(P{match}.ii-1)+ Phb*0.5;
            P{match}.Rs(P{match}.ii-1) = matchPublishUntil;
        else
            P{match}.ii = P{match}.ii+1;
            P{match}.r(P{match}.ii) = i;
            P{match}.c(P{match}.ii) = tempC;
            P{match}.P(P{match}.ii) = Phb*0.5;
            P{match}.Rs(P{match}.ii) = matchPublishUntil;
        end
    elseif matchPublishUntil == -1 && Bs < maxB && Bh < maxB % impossible to maintain same weight, publish everything
        P{match}.P(i) = 0;
        P{match}.Rh(i) = 0;
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(Bh, Bs+1, minDw, newLuckSnext, lastS, Bs);
        P{match}.P(P{match}.ii) = Psb;
        P{match}.ii = P{match}.ii+1;
        P{match}.r(P{match}.ii) = i;
        P{match}.c(P{match}.ii) = st2stnum(Bh+1, Bs, minDw+honestLuck, 0, lastH, Bs);
        P{match}.P(P{match}.ii) = Phb;
    end
    
    evenPublishUntil = -1;
    if Bs >= Bh && Dw > 0 % enough blocks to publish, possible to have honest miners work on own chain
        if published >= Bh % no more blocks need to be published
            evenPublishUntil = published;
            newDw = Dw;
        elseif last == lastH
            evenPublishUntil = Bh;
            newDw = Dw-1;
            if luckyOne == Bh
                newDw = newDw -1;
            end
        else % if last == lastS, publishing till Bh won't get the selfish miner any reward
            evenPublishUntil = Bh;
            newDw = Dw;
        end
    end

    % define even: publish until at least Bh but make sure Dw>0
    if evenPublishUntil ~= -1 && Bs < maxB
        P{even}.P(i) = 0;
        P{even}.Rh(i) = 0;
        if Bh > 0
            honestLuck = 2;
        else
            honestLuck = 1;
        end
        P{even}.ii = P{even}.ii+1;
        P{even}.r(P{even}.ii) = i;
        P{even}.P(P{even}.ii) = Psb;
        if luckyOne == Bh+1 % preserve the secret luckyOne
            P{even}.c(P{even}.ii) = st2stnum(Bh, Bs+1, newDw, 1, lastS, evenPublishUntil);
		else
		    P{even}.c(P{even}.ii) = st2stnum(Bh, Bs+1, newDw, newLuckSnext, lastS, evenPublishUntil);
        end
        P{even}.ii = P{even}.ii+1;
        P{even}.r(P{even}.ii) = i;
        P{even}.c(P{even}.ii) = st2stnum(Bh+1, Bs, newDw+honestLuck, newLuckHnext, lastH, evenPublishUntil);
        P{even}.P(P{even}.ii) = Phb;
    end
    
    % define hide: publish until Bh-1
    if published < Bh && Bh >= 1 && Bs < maxB && Bh < maxB
        P{hide}.P(i) = 0;
        P{hide}.Rh(i) = 0;
        if Bs >= Bh-1
            hidePublishUntil = Bh-1;
        else
            hidePublishUntil = Bs;
        end
        P{hide}.ii = P{hide}.ii+1;
        P{hide}.r(P{hide}.ii) = i;
        P{hide}.P(P{hide}.ii) = Psb;
		if luckyOne == Bh+1 % preserve the secret luckyOne
            P{hide}.c(P{hide}.ii) = st2stnum(Bh, Bs+1, Dw, 1, lastS, hidePublishUntil);
        else
            P{hide}.c(P{hide}.ii) = st2stnum(Bh, Bs+1, Dw, newLuckSnext, lastS, hidePublishUntil);
        end
        P{hide}.ii = P{hide}.ii+1;
        P{hide}.r(P{hide}.ii) = i;
        P{hide}.c(P{hide}.ii) = st2stnum(Bh+1, Bs, Dw+1, newLuckHnext, lastH, hidePublishUntil);
        P{hide}.P(P{hide}.ii) = Phb;
    end
end

POut = cell(1,choices);
% Rs is the reward for selfish miner
RsOut = cell(1,choices);
% Rh is the reward for honest miners
RhOut = cell(1,choices);
for i=1:choices
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

% for i=1:5
%     sumP2 = sum(P{i},2);
%     for j=1:numOfStates
%         if sumP2(j) ~= 1
%             disp([num2str(i) ' ' num2str(j) ' sum ' num2str(sumP2(j))]);
%         end
%     end
% end