addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

global alphaPower maxForkLen lowerBoundReward upperBoundReward;

maxForkLen = 80;

lowAlpha = 0.22;
highAlpha = 0.25;
epsilon = 0.0001;

while highAlpha-lowAlpha > epsilon/4
    alphaPower = (highAlpha + lowAlpha) / 2;
    InitStates;
    SolveMDP;
    if lowerBoundReward >= alphaPower+epsilon
        disp(['new highAlpha:' num2str(alphaPower)]);
        highAlpha = alphaPower;
    else
        disp(['new lowAlpha:' num2str(alphaPower)]);
        lowAlpha = alphaPower;
    end
end