global maxForkLen alphaPower numOfStates range;
global POut RsOut RhOut Wrou;
% a and h can be 0 to maxForkLen, altogether maxForkLen + 1 values
% a=h=0 is invalid
% tie=0: hWin, tie=1: aWin
hWin=0; aWin=1;
choices = 4;
% overrideSafe publish h+1 blocks when the attacker has, publish h blocks
% when the attacker doesn't have
% override would publish h blocks when possible
% note that this is slightly different from the paper but equivalent
adopt = 1; overrideSafe = 2; override = 3; wait = 4;

% allocate memory
P=cell(1,choices);
AllocateSize=zeros(1, numOfStates*range*3);
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
baseStateH = st2stnum(0, 1, hWin, 0:range-1, -1);
PsR = alphaPower/range;
baseStateS=st2stnum(1, 0, hWin, 0:range-1, -1);
PhR = (1-alphaPower)/range;
for i=1:range
    P{adopt}.r((i-1)*numOfStates+1:i*numOfStates) = 1:numOfStates;
    P{adopt}.c((i-1)*numOfStates+1:i*numOfStates) = baseStateH(i);
    P{adopt}.P((i-1)*numOfStates+1:i*numOfStates) = PhR;
end
for i=range+1:2*range
    P{adopt}.r((i-1)*numOfStates+1:i*numOfStates) = 1:numOfStates;
    P{adopt}.c((i-1)*numOfStates+1:i*numOfStates) = baseStateS(i-range);
    P{adopt}.P((i-1)*numOfStates+1:i*numOfStates) = PsR;
end
P{adopt}.ii = 2*range*numOfStates;

% define default value for other actions
for i=2:choices
    P{i}.r(1:numOfStates) = 1:numOfStates;
    P{i}.c(1:numOfStates) = baseStateH(1);
    P{i}.P(1:numOfStates) = 1;
    P{i}.Rh(1:numOfStates) = 10000;
    P{i}.ii = numOfStates;
end

for i = 1:numOfStates
    if mod(i, 10000)==0
        disp(['processing state: ' num2str(i)]);
    end
    [a, h, tie, slot1, slot2] = stnum2st(i);
    if a<h
        htop = slot1;
    else
        atop1 = slot1; atop2 = slot2;
    end
    P{adopt}.Rh(i:numOfStates:(range*2-1)*numOfStates+i) = h;
    
    % define overrideSafe
    % first clear the default case by setting the probability to zero
    if a==h && tie==aWin || a>h
        P{overrideSafe}.P(i) = 0;
        P{overrideSafe}.Rh(i) = 0;
    end
    if a==h+1 || a==h && tie==aWin % publish everything
        P{overrideSafe}.r(P{overrideSafe}.ii+1:P{overrideSafe}.ii+2*range) = i;
        P{overrideSafe}.Rs(P{overrideSafe}.ii+1:P{overrideSafe}.ii+2*range) = a;
		% next by h
        P{overrideSafe}.c(P{overrideSafe}.ii+1:P{overrideSafe}.ii+range) = baseStateH(1:range);
        P{overrideSafe}.P(P{overrideSafe}.ii+1:P{overrideSafe}.ii+range) = PhR;
		% next by a
        P{overrideSafe}.c(P{overrideSafe}.ii+range+1:P{overrideSafe}.ii+2*range) = baseStateS(1:range);
        P{overrideSafe}.P(P{overrideSafe}.ii+range+1:P{overrideSafe}.ii+2*range) = PsR;
        P{overrideSafe}.ii = P{overrideSafe}.ii+2*range;
    elseif a>h+1 % publish h+1 blocks anyway!
		% next by a
        P{overrideSafe}.r(P{overrideSafe}.ii+1:P{overrideSafe}.ii+range) = i;
        P{overrideSafe}.Rs(P{overrideSafe}.ii+1:P{overrideSafe}.ii+range) = h+1;
        P{overrideSafe}.c(P{overrideSafe}.ii+1:P{overrideSafe}.ii+range) = st2stnum(a-h, 0, hWin, 0:range-1, atop1);
        P{overrideSafe}.P(P{overrideSafe}.ii+1:P{overrideSafe}.ii+range) = PsR;
        P{overrideSafe}.ii = P{overrideSafe}.ii+range;
		% next by h
		if a==h+2
            P{overrideSafe}.ii = P{overrideSafe}.ii+1;
            P{overrideSafe}.r(P{overrideSafe}.ii) = i;
            P{overrideSafe}.Rs(P{overrideSafe}.ii) = h+1;
            P{overrideSafe}.c(P{overrideSafe}.ii) = st2stnum(1, 1, aWin, -1, -1);
            P{overrideSafe}.P(P{overrideSafe}.ii) = PhR*(range-1-atop1);
            P{overrideSafe}.ii = P{overrideSafe}.ii+1;
            P{overrideSafe}.r(P{overrideSafe}.ii) = i;
            P{overrideSafe}.Rs(P{overrideSafe}.ii) = h+1;
            P{overrideSafe}.c(P{overrideSafe}.ii) = st2stnum(1, 1, hWin, -1, -1);
            P{overrideSafe}.P(P{overrideSafe}.ii) = PhR*(1+atop1);
        elseif a==h+3
		    P{overrideSafe}.ii = P{overrideSafe}.ii+1;
            P{overrideSafe}.r(P{overrideSafe}.ii) = i;
            P{overrideSafe}.Rs(P{overrideSafe}.ii) = h+1;
            P{overrideSafe}.c(P{overrideSafe}.ii) = st2stnum(2, 1, aWin, atop1, -1);
            P{overrideSafe}.P(P{overrideSafe}.ii) = PhR*(range-1-atop2);
            P{overrideSafe}.ii = P{overrideSafe}.ii+1;
            P{overrideSafe}.r(P{overrideSafe}.ii) = i;
            P{overrideSafe}.Rs(P{overrideSafe}.ii) = h+1;
            P{overrideSafe}.c(P{overrideSafe}.ii) = st2stnum(2, 1, hWin, atop1, -1);
            P{overrideSafe}.P(P{overrideSafe}.ii) = PhR*(1+atop2);
		else % a>h+3
		    P{overrideSafe}.ii = P{overrideSafe}.ii+1;
            P{overrideSafe}.r(P{overrideSafe}.ii) = i;
            P{overrideSafe}.Rs(P{overrideSafe}.ii) = h+1;
            P{overrideSafe}.c(P{overrideSafe}.ii) = st2stnum(a-h-1, 1, hWin, atop1, atop2);
            P{overrideSafe}.P(P{overrideSafe}.ii) = 1-alphaPower;
		end 
    end
    
    % define override, which only applies when the attacker chooses to
    %   publish h blocks when he has >h blocks
    if a==h+1 && tie==aWin
        P{override}.P(i) = 0;
        P{override}.Rh(i) = 0;
        % next by h
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = st2stnum(1, 1, aWin, -1, -1);
        P{override}.P(P{override}.ii) = PhR*(range-1-atop1);
		P{override}.Rs(P{override}.ii) = h;
        P{override}.ii = P{override}.ii+1;
        P{override}.r(P{override}.ii) = i;
        P{override}.c(P{override}.ii) = st2stnum(1, 1, hWin, -1, -1);
        P{override}.P(P{override}.ii) = PhR*(1+atop1);
		P{override}.Rs(P{override}.ii) = h;
        % next by a
        P{override}.r(P{override}.ii+1:P{override}.ii+range) = i;
        P{override}.c(P{override}.ii+1:P{override}.ii+range) = st2stnum(2, 0, hWin, 0:range-1, atop1);
        P{override}.P(P{override}.ii+1:P{override}.ii+range) = PsR;
		P{override}.Rs(P{override}.ii+1:P{override}.ii+range) = h;
        P{override}.ii = P{override}.ii+range;
    end
    
    % define wait
    if a+1 <= maxForkLen && h+1 <= maxForkLen
        P{wait}.P(i) = 0;
        P{wait}.Rh(i) = 0;
		% next by h
		if a<=h
		    P{wait}.r(P{wait}.ii+1:P{wait}.ii+range) = i;
            P{wait}.c(P{wait}.ii+1:P{wait}.ii+range) = st2stnum(a, h+1, hWin, 0:range-1, -1);
            P{wait}.P(P{wait}.ii+1:P{wait}.ii+range) = PhR;
            P{wait}.ii = P{wait}.ii+range;
		elseif a==h+1
		    P{wait}.ii = P{wait}.ii+1;
			P{wait}.r(P{wait}.ii) = i;
			P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, aWin, -1, -1);
			P{wait}.P(P{wait}.ii) = PhR*(range-1-atop1);
			P{wait}.ii = P{wait}.ii+1;
			P{wait}.r(P{wait}.ii) = i;
			P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, hWin, -1, -1);
			P{wait}.P(P{wait}.ii) = PhR*(1+atop1);
		elseif a==h+2
		    P{wait}.ii = P{wait}.ii+1;
			P{wait}.r(P{wait}.ii) = i;
			P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, aWin, atop1, -1);
			P{wait}.P(P{wait}.ii) = PhR*(range-1-atop2);
			P{wait}.ii = P{wait}.ii+1;
			P{wait}.r(P{wait}.ii) = i;
			P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, hWin, atop1, -1);
			P{wait}.P(P{wait}.ii) = PhR*(1+atop2);
		elseif a>h+2
			P{wait}.ii = P{wait}.ii+1;
			P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a, h+1, hWin, atop1, atop2);
            P{wait}.P(P{wait}.ii) = 1-alphaPower;
		end
        % next by a
        if a<h-1
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a+1, h, hWin, htop, -1);
            P{wait}.P(P{wait}.ii) = alphaPower;
        elseif a==h-1
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a+1, h, aWin, -1, -1);
            P{wait}.P(P{wait}.ii) = PsR*htop;
            P{wait}.ii = P{wait}.ii+1;
            P{wait}.r(P{wait}.ii) = i;
            P{wait}.c(P{wait}.ii) = st2stnum(a+1, h, hWin, -1, -1);
            P{wait}.P(P{wait}.ii) = PsR*(range-htop);
        elseif a==h
            P{wait}.r(P{wait}.ii+1:P{wait}.ii+range) = i;
            P{wait}.c(P{wait}.ii+1:P{wait}.ii+range) = st2stnum(a+1, h, tie, 0:range-1, -1);
            P{wait}.P(P{wait}.ii+1:P{wait}.ii+range) = PsR;
            P{wait}.ii = P{wait}.ii+range;
        elseif a>h
            P{wait}.r(P{wait}.ii+1:P{wait}.ii+range) = i;
            P{wait}.c(P{wait}.ii+1:P{wait}.ii+range) = st2stnum(a+1, h, hWin, 0:range-1, atop1);
            P{wait}.P(P{wait}.ii+1:P{wait}.ii+range) = PsR;
            P{wait}.ii = P{wait}.ii+range;
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

mdp_check(POut, RsOut);

% for i=1:choices
%     sumP2 = sum(POut{i},2);
%     for j=1:numOfStates
%         if sumP2(j) < 0.99 || sumP2(j)>1.01
%             disp(['action=' num2str(i) ' state=' num2str(j) ' sum=' num2str(sumP2(j))]);
%             [a, h, tie, slot1, slot2] = stnum2st(j);
%             disp(['a=' num2str(a) ' h=' num2str(h) ' tie=' num2str(tie)...
%                 ' slot1=' num2str(slot1) ' slot2=' num2str(slot2)]);
%             break
%         end
%     end
% end
