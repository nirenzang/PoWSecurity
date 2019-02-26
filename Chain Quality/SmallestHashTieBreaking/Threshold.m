addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% maxForkLen is the maximum length of a block fork
global alphaPower maxForkLen range lowerBoundReward upperBoundReward;

range = 15; % hash value, when range=10, 0 means 0 to 0.1, 1 means 0.1 to 0.2...9 means 0.9 to 1.0
maxForkLen = 40;
InitStnum;

lowAlpha = 0;
highAlpha = 0.1;
epsilon = 0.0001;

while highAlpha-lowAlpha > epsilon/2
    alphaPower = (highAlpha + lowAlpha) / 2;
    InitStates;
    SolveMDP;
    if lowerBoundReward > alphaPower
        disp(['new highAlpha:' num2str(alphaPower)]);
        highAlpha = alphaPower;
    else
        disp(['new lowAlpha:' num2str(alphaPower)]);
        lowAlpha = alphaPower;
    end
end