addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% gammaRatio is the proportion of honest miners that would mine on the
%     attacker's chain during a tie; in this MDP it can only be 0 or 1
% maxForkLen is the maximum length of a block fork
% bfRatio is the difficulty ratio between blocks and fruit
% DSR stands for "double spending reward"
% cfN stands for "confirmation number"
global alphaPower gammaRatio bfRatio DSR cfN;
global maxForkLen maxafa maxhf timeOut reward

alphaGroup = [0.45 0.4 0.35 0.3 0.25 0.2 0.15 0.1];
DSR = 3;
cfN = 6;
bfRatio = 1;
maxForkLen = 24;
maxafa = 35;
maxhf = 45;
timeOut = 7; % attacker fruits within timeOut-1 blocks: always receive rewards
InitStnum;


gammaRatio = 1;
RewardOne = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    RewardOne = [RewardOne reward];
end
