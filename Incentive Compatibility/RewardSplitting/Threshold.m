addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% gammaRatio is the proportion of honest miners that would mine on the
%     attacker's chain during a tie
% maxForkLen is the maximum length of a block fork
global alphaPower gammaRatio maxForkLen timeOut maxHistoryLen

maxForkLen = 30;
timeOut = 9;
gammaRatio = 0;
maxHistoryLen = timeOut-1;
InitStnum;

lowAlpha = 0.3702;
highAlpha = 0.3787;
epsilon = 0.0001;

while highAlpha-lowAlpha > epsilon/2
    alphaPower = (highAlpha + lowAlpha) / 2
    InitStates;
    SolveMDP;
    if rou >= alphaPower+0.0001
        disp(['new highAlpha:' num2str(alphaPower)]);
        highAlpha = alphaPower;
    elseif rou <= alphaPower+0.00002
        disp(['new lowAlpha:' num2str(alphaPower)]);
        lowAlpha = alphaPower;
	else
		break
    end
end

disp(['converge: ' num2str(alphaPower)])

alphaPower = round(highAlpha*10000)/10000

while 1
	alphaPower = alphaPower-0.0001
	InitStates;
    SolveMDP;
	if rou <= alphaPower+0.000025
		break
	end
end

disp(['output: ' num2str(alphaPower)])
