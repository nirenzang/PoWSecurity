addpath('/users/cosic/rzhang/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');

clear

% alphaPower is the mining power share of the attacker
% gammaRatio is the proportion of honest miners that would mine on the
%     attacker's chain during a tie
% maxForkLen is the maximum length of a block fork
global alphaPower gammaRatio maxForkLen timeOut maxHistoryLen DSR cfN
global lowerBoundPolicy baseStateS

maxForkLen = 30;
alphaGroup = [0.1 0.2 0.3 0.4];
cfNGroup = [3 6];
gammaRatio = 0.95;

lowBountyCfN = [];
for cfN = cfNGroup
    timeOut = cfN;
    maxHistoryLen = timeOut-1;
    InitStnum;
    for alphaPower = alphaGroup
        highDSR = 10;
        lowDSR = 0;
        DSR = highDSR;
        while 1
            InitStates;
            SolveMDP;
            if lowerBoundPolicy(baseStateS) ~= 2
                highDSR = highDSR*2;
                lowDSR = highDSR;
                DSR = highDSR;
            else
                break
            end
        end
        while highDSR-lowDSR > 0.00005
            DSR = (highDSR+lowDSR)/2;
            InitStates;
            SolveMDP;
            if lowerBoundPolicy(baseStateS) == 2
                highDSR = DSR
            else
                lowDSR = DSR
            end
        end
        lowBountyCfN = [lowBountyCfN lowDSR];
        disp(['cfN=' num2str(cfN) ' alpha=' num2str(alphaPower) ' subversionBounty=' num2str(lowDSR)]);
    end
end