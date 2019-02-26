global POut RsOut RhOut Wrou lowerBoundReward upperBoundReward range alphaPower;

epsilon = 0.0008;
% the precision is lower for faster convergence

lowRou = alphaPower*0.99;
highRou = alphaPower/(1-alphaPower);
while(highRou - lowRou > epsilon/8)
    rou = (highRou + lowRou) / 2;
    for i = 1:choices
        Wrou{i} = (1-rou).*RsOut{i} - rou.*RhOut{i};
    end
    [lowerBoundPolicy reward cpuTime] = mdp_relative_value_iteration(POut, Wrou, epsilon/8);
    if(reward > 0)
        disp(['new lowRou:' num2str(rou)]);
        lowRou = rou;
    else
        disp(['new highRou:' num2str(rou)]);
        highRou = rou;
    end
end
disp('lowerBoundReward: ')
format long
lowerBoundReward = lowRou;
disp(rou)

% lowerBoundRou = rou;
% lowRou = rou;
% highRou = min(rou + 0.1, 1);
% while(highRou - lowRou > epsilon/8)
%     rou = (highRou + lowRou) / 2;
%     for i=1:numOfStates
%         [a, h, fork] = stnum2st(i);
%         if a == maxForkLen
%             mid1 = (1-rou)*alphaPower*(1-alphaPower)/(1-2*alphaPower)^2+0.5*((a-h)/(1-2*alphaPower)+a+h);
%             RsOut{adopt}(i, st2stnum(1, 0, hWin, 0, -1)) = mid1;
%             RsOut{adopt}(i, st2stnum(0, 1, hWin, range-1, -1)) = mid1;
%             RhOut{adopt}(i, st2stnum(1, 0, hWin, 0, -1)) = 0;
%             RhOut{adopt}(i, st2stnum(0, 1, hWin, range-1, -1)) = 0;
%         elseif h == maxForkLen
%             mid1=alphaPower*(1-alphaPower)/((1-2*alphaPower)^2);
%             mid2=(alphaPower/(1-alphaPower))^(h-a);
%             mid3=(1-mid2)*(0-rou)*h+mid2*(1-rou)*(mid1+(h-a)/(1-2*alphaPower));
%             RsOut{adopt}(i, st2stnum(1, 0, hWin, 0, -1)) = mid3;
%             RsOut{adopt}(i, st2stnum(0, 1, hWin, range-1, -1)) = mid3;
%             RhOut{adopt}(i, st2stnum(1, 0, hWin, 0, -1)) = 0;
%             RhOut{adopt}(i, st2stnum(0, 1, hWin, range-1, -1)) = 0;
%         end
%     end
%     for i = 1:choices
%         Wrou{i} = (1-rou).*RsOut{i} - rou.*RhOut{i};
%     end
%     rouPrime = max(lowRou-epsilon/4, 0);
%     [upperBoundPolicy reward cpuTime] = mdp_relative_value_iteration(POut, Wrou, epsilon/8);
%     if(reward > 0)
%         lowRou = rou;
%     else
%         highRou = rou;
%     end
% end
% disp('upperBoundReward: ')
% upperBoundReward = rou;
% disp(rou)
