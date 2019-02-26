global POut RsOut RhOut alphaPower rou
choices = 5;
for i = 1:choices
    Wrou{i} = sparse(numOfStates, numOfStates);
end
disp(mdp_check(POut, RsOut));

epsilon = 0.0001;

lowRou = alphaPower;
highRou = alphaPower/(1-alphaPower);
while(highRou - lowRou > epsilon/8)
    rou = (highRou + lowRou) / 2;
    for i = 1:choices
        Wrou{i} = (1-rou).*RsOut{i} - rou.*RhOut{i};
    end
    [lowerBoundPolicy reward cpuTime] = mdp_relative_value_iteration(POut, Wrou, epsilon/8);
    if(reward > 0)
        disp(['newLowRou' num2str(rou)]);
        lowRou = rou;
    else
        disp(['newHighRou' num2str(rou)]);
        highRou = rou;
    end
end
format long
disp(['alpha: ' num2str(alphaPower) ' lowerBoundReward: ']);
disp(rou);