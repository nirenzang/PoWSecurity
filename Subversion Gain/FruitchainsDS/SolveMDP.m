global POut RsOut reward bfRatio

disp(mdp_check(POut, RsOut))

epsilon = 0.0001;

[lowerBoundPolicy reward cpuTime] = mdp_relative_value_iteration(POut, RsOut, epsilon/8);
disp('expectedReward: ')
format long
reward = reward*(1+bfRatio);
disp(reward)
disp('cpuTime')
disp(cpuTime)