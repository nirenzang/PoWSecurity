addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

global alphaPower maxB superOverride rou;

maxB = 30; % the maximum length of a block race. Note that the program becomes slow if maxB>12.
superOverride = 3; % k in the paper. The attacker can override if he is k blocks ahead even with a lighter chain.

alphaGroup = [0.4 0.35 0.3];

RewardResult = [];
for alphaPower = alphaGroup
    InitStates;
    SolveMDP;
    RewardResult = [RewardResult rou];
end
