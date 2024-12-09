function [best_params,fval,tElapsed] = run_geneticDiscr(DataSystem, VarSystem, x0, lb, ub) 
% Оптимизация lambda
sse_func  = @(x) getFunctionSystemUnoDiscr(x, DataSystem, VarSystem);

    opts = optimoptions(@ga, ...
                        'PopulationSize', 20, ...
                        'MaxGenerations', 100, ...
                        'EliteCount', 10, ...
                        'FunctionTolerance', 1e-8, ...
                        'PlotFcn', @gaplotbestfun);
    opts.InitialPopulationMatrix = x0;

tStart = tic;

[best_params, fval, exitflag] = ga(sse_func, 5, [], [], [], [], ...
    lb, ub, [], 1:5, opts);

best_params=best_params+1;

tElapsed = toc(tStart); 

end