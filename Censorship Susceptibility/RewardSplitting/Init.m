addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% gammaRatio is the proportion of honest miners that would mine on the
%     attacker's chain during a tie
% maxForkLen is the maximum length of a block fork
global alphaPower gammaRatio maxForkLen timeOut maxHistoryLen

maxForkLen = 40;
timeOut = 6;
maxHistoryLen = timeOut-1;
InitStnum;

alphaGroup = [0.45 0.4 0.35 0.3 0.25 0.2 0.15 0.1];

gammaRatio = 0;
lowerBoundRewardZero = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    lowerBoundRewardZero = [lowerBoundRewardZero rou];
end

gammaRatio = 0.5;
lowerBoundRewardHalf = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    lowerBoundRewardHalf = [lowerBoundRewardHalf rou];
end

gammaRatio = 1;
lowerBoundRewardOne = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    lowerBoundRewardOne = [lowerBoundRewardOne rou];
end
