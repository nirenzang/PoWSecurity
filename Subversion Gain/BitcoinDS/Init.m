addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% gammaRatio is the proportion of honest miners that would mine on the
%     attacker's chain during a tie
% maxForkLen is the maximum length of a block fork
global alphaPower gammaRatio maxForkLen DSR cfN reward;
% DSR stands for "double spending reward"
% cfN stands for "confirmation number"

alphaGroup = [0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45];
DSR = 3;
cfN = 6;

gammaRatio = 1;
RewardOne = [];
maxForkLen = 24;
for alphaPower = alphaGroup
    %if alphaPower <= 0.4
    %    maxForkLen = 80;
    %else
    %    maxForkLen = 160;
    %end
    InitStates;
    SolveMDP;
    RewardOne = [RewardOne reward];
end
