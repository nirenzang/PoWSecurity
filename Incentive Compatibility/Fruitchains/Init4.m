addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% gammaRatio is the proportion of honest miners that would mine on the
%     attacker's chain during a tie; in this MDP it can only be 0 or 1
% maxForkLen is the maximum length of a block fork
% bfRatio is the difficulty ratio between blocks and fruit
% DSR stands for "double spending reward"
% cfN stands for "confirmation number"
global alphaPower gammaRatio bfRatio
global maxForkLen maxafa maxhf timeOut rou

bfRatio = 0.5; % average fruit per block, 2 means 1/3 blocks, 2/3 fruits; 1: 1/2 blocks, 1/2 fruits
maxForkLen = 20;
maxafa = 10;
maxhf = 40;
timeOut = 13; % attacker fruits within timeOut-1 blocks: always receive rewards
InitStnum;

alphaGroup = [0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45];


gammaRatio = 0
lowerBoundRewardZero = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    lowerBoundRewardZero = [lowerBoundRewardZero rou];
end

gammaRatio = 1
lowerBoundRewardOne = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    lowerBoundRewardOne = [lowerBoundRewardOne rou];
end
