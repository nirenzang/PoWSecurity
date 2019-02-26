global POut RsOut reward mtimes

disp(mdp_check(POut, RsOut))

epsilon = 0.0001;

[lowerBoundPolicy reward cpuTime] = mdp_relative_value_iteration(POut, RsOut, epsilon/8);
reward = reward*mtimes;
disp('expectedReward: ')
format long
disp(reward)
disp('cpuTime')
disp(cpuTime)