addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

global alphaPower maxB superOverride rou;

maxB = 20; % the maximum length of a block race. Note that the program becomes slow if maxB>12.
superOverride = 3; % k in the paper. The attacker can override if he is k blocks ahead even with a lighter chain.

lowAlpha = 0.25;
highAlpha = 0.275;
epsilon = 0.0001;

while highAlpha-lowAlpha > epsilon/2
    alphaPower = (highAlpha + lowAlpha) / 2;
    InitStates;
    SolveMDP;
    if rou >= alphaPower+0.0001
        disp(['new highAlpha:' num2str(alphaPower)]);
        highAlpha = alphaPower;
    else
        disp(['new lowAlpha:' num2str(alphaPower)]);
        lowAlpha = alphaPower;
    end
end