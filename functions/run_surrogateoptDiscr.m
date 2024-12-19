function [best_params, fval, tElapsed] = run_surrogateoptDiscr(DataSystem,VarSystem, lb, ub, numVar,numStarts)  
% Оптимизация lambda 
sse_func = @(x) getFunctionSystemUnoDiscr(x, DataSystem, VarSystem);

% Опции для surrogateopt
opts = optimoptions(@surrogateopt, ... 
                    'MaxFunctionEvaluations', numStarts,... 
                    'PlotFcn', @surrogateoptplot); 

% Установка начальной точки
% opts.InitialPopulationMatrix = x0;

tStart = tic; 

[best_params, fval] = surrogateopt(sse_func, lb, ub, 1:numVar, opts); 
best_params = best_params + 1;  
tElapsed = toc(tStart);  

end
