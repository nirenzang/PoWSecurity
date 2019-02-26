addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% gammaRatio is the proportion of honest miners that would mine on the
%     attacker's chain during a tie
% maxForkLen is the maximum length of a block fork
global alphaPower gammaRatio maxForkLen lowerBoundReward upperBoundReward;

alphaGroup = [0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45];

gammaRatio = 0;
lowerBoundRewardZero = [];
upperBoundRewardZero = [];
maxForkLen = 40;
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    lowerBoundRewardZero = [lowerBoundRewardZero lowerBoundReward];
    upperBoundRewardZero = [upperBoundRewardZero upperBoundReward];
end

gammaRatio = 0.5;
lowerBoundRewardHalf = [];
upperBoundRewardHalf = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    lowerBoundRewardHalf = [lowerBoundRewardHalf lowerBoundReward];
    upperBoundRewardHalf = [upperBoundRewardHalf upperBoundReward];
end

gammaRatio = 1;
lowerBoundRewardOne = [];
upperBoundRewardOne = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    lowerBoundRewardOne = [lowerBoundRewardOne lowerBoundReward];
    upperBoundRewardOne = [upperBoundRewardOne upperBoundReward];
end


% Please note that for larger alpha, the gap between uppper and lower bound
%     would be larger. It takes a larger maxForkLen for these two bounds to
%     converge. Even 160 is not always enough.


