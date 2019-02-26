addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% gammaRatio is the proportion of honest miners that would mine on the
%     attacker's chain during a tie
% maxForkLen is the maximum length of a block fork
global alphaPower gammaRatio maxForkLen timeOut maxHistoryLen DSR cfN reward

DSR = 3;
cfN = 6;
maxForkLen = 24;
timeOut = 6;
maxHistoryLen = timeOut-1;
InitStnum;

alphaGroup = [0.45 0.4 0.35 0.3 0.25 0.2 0.15 0.1];
gammaRatio = 1;
lowerBoundRewardOne = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    lowerBoundRewardOne = [lowerBoundRewardOne reward];
end
