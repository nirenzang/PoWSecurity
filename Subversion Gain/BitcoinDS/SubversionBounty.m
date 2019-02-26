addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% gammaRatio is the proportion of honest miners that would mine on the
%     attacker's chain during a tie
% maxForkLen is the maximum length of a block fork
global alphaPower gammaRatio maxForkLen DSR cfN reward lowerBoundPolicy baseStateS override
% DSR stands for "double spending reward"
% cfN stands for "confirmation number"

alphaGroup = [0.1 0.2 0.3 0.4];
cfNGroup = [3 6];
gammaRatio = 0.95;

cfN = 3;

lowBountyCfN = [];
for cfN = cfNGroup
    for alphaPower = alphaGroup
        if alphaPower <= 0.4
            maxForkLen = 80;
        else
            maxForkLen = 160;
        end
        highDSR = 800;
        lowDSR = 0;
        while highDSR-lowDSR > 0.00005
            DSR = (highDSR+lowDSR)/2;
            InitStates;
            SolveMDP;
            if lowerBoundPolicy(baseStateS) ~= override
                highDSR = DSR
            else
                lowDSR = DSR
            end
        end
        lowBountyCfN = [lowBountyCfN lowDSR];
        disp(['cfN=' num2str(cfN) ' alpha=' num2str(alphaPower) ' subversionBounty=' num2str(lowDSR)]);
    end
end