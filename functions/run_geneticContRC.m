function [best_params,fval,tElapsed] = run_geneticContRC(DataSystem, IteratorCapacitor, IteratorDiod, IteratorResistor_B, IteratorResistor_K, IteratorTransistor,... 
                              t, U_ratio, iRelative, power_b, resistance_b, P_ratio_b, power_k, P_ratio_k,... 
                              pRelative, s1, ... 
                              x0, lb, ub) 
% Оптимизация lambda
sse_func = @(x) getReliabilitySystemFromData(DataSystem,...
    IteratorCapacitor, IteratorDiod, IteratorResistor_B, IteratorResistor_K, IteratorTransistor,...
    t, x(1), U_ratio, iRelative, power_b, resistance_b, P_ratio_b,...
    power_k, x(2), P_ratio_k, pRelative, s1);

opts = optimoptions(@ga, ... 
                    'PopulationSize', 20, ... 
                    'MaxGenerations', 20, ... % Увеличение для лучшего поиска
                    'EliteCount', 10, ... 
                    'FunctionTolerance', 1e-8, ... 
                    'CrossoverFraction', 0.1, ... % Увеличиваем кроссовер
                    'MutationFcn', @mutationadaptfeasible, ... % Используем адаптивную мутацию
                    'PlotFcn', @gaplotbestf, ...
                    'SelectionFcn', @selectiontournament, ...
                    'UseParallel', true); % Если возможно, используйте параллельные вычисления
opts.InitialPopulationMatrix = x0;

% disp("Start optimization at " + datestr(datetime()));
tStart = tic;

[best_params, fval, exitflag] = ga(sse_func, 2, [], [], [], [], ...
    lb, ub, [], [], opts);
% disp("Finish optimization at " + datestr(datetime())); 
tElapsed = toc(tStart); 
% disp("Elapsed time: " + num2str(tElapsed) + " sec"); 

end