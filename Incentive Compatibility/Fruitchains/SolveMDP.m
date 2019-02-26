global POut RsOut RhOut Wrou rou

disp(mdp_check(POut, RsOut))

epsilon = 0.0001;

lowRou = 0;
highRou = 1;
while(highRou - lowRou > epsilon/8)
    rou = (highRou + lowRou) / 2;
    for i = 1:choices
        Wrou{i} = (1-rou).*RsOut{i} - rou.*RhOut{i};
    end
    [lowerBoundPolicy reward cpuTime] = mdp_relative_value_iteration(POut, Wrou, epsilon/8);
    if(reward > 0)
        lowRou = rou;
    else
        highRou = rou;
    end
end
disp('lowerBoundReward: ')
format long
disp(rou)