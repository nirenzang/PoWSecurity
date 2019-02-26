addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% maxForkLen is the maximum length of a block fork
global alphaPower maxForkLen range lowerBoundReward upperBoundReward;

range = 15; % hash value, when range=10, 0 means 0 to 0.1, 1 means 0.1 to 0.2...9 means 0.9 to 1.0
maxForkLen = 40;
InitStnum;

% alphaGroup = [0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45];
alphaGroup = [0.1];


% Please note that for larger alpha, the gap between uppper and lower bound
%     would be larger. It takes a larger maxForkLen for these two bounds to
%     converge. Even 160 is not always enough.
lowerBoundRewardResult = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    lowerBoundRewardResult = [lowerBoundRewardResult lowerBoundReward];
end
