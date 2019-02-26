addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% gammaRatio is the proportion of honest miners that would mine on the
%     attacker's chain during a tie
% maxForkLen is the maximum length of a block fork
global alphaPower gammaRatio maxForkLen lowerBoundReward upperBoundReward;

alphaGroup = [0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45];

% Please note that for larger alpha, the gap between uppper and lower bound
%     would be larger. It takes a larger maxForkLen for these two bounds to
%     converge. Even 160 is not always enough.
gammaRatio = 0.5;
lowerBoundRewardHalf = [];
upperBoundRewardHalf = [];
for alphaPower = alphaGroup
    if alphaPower <= 0.4
        maxForkLen = 80;
    else
        maxForkLen = 160;
    end
    InitStates;
    SolveMDP;
    lowerBoundRewardHalf = [lowerBoundRewardHalf lowerBoundReward];
    upperBoundRewardHalf = [upperBoundRewardHalf upperBoundReward];
end
