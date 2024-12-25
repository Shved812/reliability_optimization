clc; clear; close all;

%% Includes
addpath("functions\");
addpath("Models\");
addpath("Models\capacitors\");
addpath("Models\capacitors\functions\");
addpath("Models\diods\");
addpath("Models\diods\functions\");
addpath("Models\resistors\");
addpath("Models\resistors\functions\");
addpath("Models\transistors\")  
addpath("Models\transistors\functions\");

%% 
FilenameSystem.Capacitors = 'table_reliability_capacitor.xlsx';
FilenameSystem.Diods = 'table_reliability_diod.xlsx';
FilenameSystem.Resistors = 'table_reliability_resistor.xlsx';
FilenameSystem.Transistors = 'table_reliability_transistor.xlsx';

%% Script param
[DataSystem] = getTableSystemData(FilenameSystem);
[VarSystem] = getVarSystem();
global drawing;
drawing.f = []; % Инициализация массива f
drawing.x = []; % Инициализация массива x

x0 = [3e5 3e5]; 
lb = [1e3 1e3]; 
ub = [.5e6 .5e6]; 
numStarts = 100; 
plot_num = [];
fig = [];
plot_dens = 70;
opt_mod = 1;

%% строить поверхность долго
% Задаем диапазоны значений
resistance_b_range  = linspace(lb(1), ub(1), plot_dens);
resistance_be_range = linspace(lb(2), ub(2), plot_dens);

% Создаем сетку значений
[ResistanceBEGrid, ResistanceBGrid] = meshgrid(resistance_be_range, resistance_b_range);

% Расчёт оптимизируемой функции
% [output] = putUnoContTable(resistance_b_range,resistance_be_range);

lambda_surface = load("lambda1","lambda_surface");
% Построение 3D поверхности
figure;
surf(ResistanceBEGrid, ResistanceBGrid, lambda_surface.lambda_surface,'EdgeColor','none');
%%
% Находим минимальное значение в матрице и его индекс
[minValue, linearIndex] = min(lambda_surface.lambda_surface(:));

% Преобразуем линейный индекс в двумерные индексы (строка и столбец)
[row, col] = ind2sub(size(lambda_surface.lambda_surface), linearIndex);
hold on
sc = scatter3(ResistanceBEGrid(row,col),ResistanceBGrid(row,col),lambda_surface.lambda_surface(row,col),'red','square','filled','SizeData',400); 
dt=datatip(sc);
% Задаем размер матрицы

% Создаем матрицу размером 70x70 с одинаковыми строками
matrixString = strings(height(ResistanceBGrid), width(ResistanceBGrid));

% Заполняем матрицу одинаковым элементом
matrixString(:) = "TrueMinimum"; % замените "element" на желаемое 

aa = dataTipTextRow('label',matrixString);
sc.DataTipTemplate.DataTipRows(end+1) = aa;

hold off
xlabel('X: Resistance_{be} (Ω)');
ylabel('Y: Resistance_{b} (Ω)');
zlabel('Z: Lambda (Failure Rate)');
title(' ');
colorbar; % Добавляем цветовую панель для обозначения значений lambda

if(opt_mod == 1)
    %% Direct opt
    %% Multistart
    [best_params,fval,tElapsed] = run_multistartContRC(DataSystem, VarSystem, x0, lb, ub, numStarts) 
    [fig, plot_num] = plotParam(fig, plot_num, x0, VarSystem, DataSystem, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"Multistart",tElapsed);
    
    %% Globalsearch
    [best_params,fval,tElapsed] = run_globalsearchContRC(DataSystem, VarSystem, x0, lb, ub, numStarts) 
    [fig, plot_num] = plotParam(fig, plot_num, x0, VarSystem, DataSystem, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"Globalsearch",tElapsed);
    
    %% Genetic 
    [best_params,fval,tElapsed] = run_geneticContRC(DataSystem, VarSystem, x0, lb, ub, numStarts) 
    [fig, plot_num] = plotParam(fig, plot_num, x0, VarSystem, DataSystem, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"Genetic",tElapsed);
    
    %% PatternSearch
    [best_params, fval, tElapsed] = run_patternSearchContRC(DataSystem, VarSystem, x0, lb, ub, numStarts) 
    [fig, plot_num] = plotParam(fig, plot_num, x0, VarSystem, DataSystem, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"PatternSearch",tElapsed);
    
    %% Simulated Annealing
    [best_params, fval, tElapsed] = run_simulatedAnnealingContRC(DataSystem, VarSystem, x0, lb, ub, numStarts)
    [fig, plot_num] = plotParam(fig, plot_num, x0, VarSystem, DataSystem, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"Simulated Annealing",tElapsed);
    
    %% Surrogate 
    [best_params,fval,tElapsed] = run_surrogateContRC(DataSystem, VarSystem, lb, ub, numStarts)
    [fig, plot_num] = plotParam(fig, plot_num, x0, VarSystem, DataSystem, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"Surrogate",tElapsed);
elseif(opt_mod == 2)
    %% Statistic opt
    numOpts = 10;
    numStarts = 25;
    numPoint = [10, 10];
    
    k_range = [0.1, 0.1];
    range_delta = [(ub(1)-lb(1)), (ub(2)-lb(2))];
    lb_opt_space = [lb(1)+range_delta(1)*k_range(1), lb(2)+range_delta(2)*k_range(2)];
    ub_opt_space = [ub(1)-range_delta(1)*k_range(1), ub(2)-range_delta(2)*k_range(2)];
    x0_matr = [(linspace(lb_opt_space(1),ub_opt_space(1),numPoint(1)))',...
        (linspace(lb_opt_space(2),ub_opt_space(2),numPoint(2)))'];

    best_params = zeros(6, length(x0_matr), numOpts, 2);
    fval        = zeros(6, length(x0_matr), numOpts);
    tElapsed    = zeros(6, length(x0_matr), numOpts);

    for i = 1:length(x0_matr)
        % for j = 1:length(x0_matr)
        for k = 1:numOpts
    %% Multistart
    [best_params(1,i,k,:),fval(1,i,k),tElapsed(1,i,k)] = run_multistartContRC(DataSystem, VarSystem, x0_matr(i,:), lb, ub, numStarts);
    % [fig, plot_num] = plotParam(fig, plot_num, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"Multistart",tElapsed);
    
    %% Globalsearch
    [best_params(2,i,k,:),fval(2,i,k),tElapsed(2,i,k)] = run_globalsearchContRC(DataSystem, VarSystem, x0_matr(i,:), lb, ub, numStarts);
    % [fig, plot_num] = plotParam(fig, plot_num, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"Globalsearch",tElapsed);

    %% Genetic 
    [best_params(3,i,k,:),fval(3,i,k),tElapsed(3,i,k)] = run_geneticContRC(DataSystem, VarSystem, x0_matr(i,:), lb, ub, numStarts);
    % [fig, plot_num] = plotParam(fig, plot_num, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"Genetic",tElapsed);

    %% PatternSearch
    [best_params(4,i,k,:), fval(4,i,k), tElapsed(4,i,k)] = run_patternSearchContRC(DataSystem, VarSystem, x0_matr(i,:), lb, ub, numStarts);
    % [fig, plot_num] = plotParam(fig, plot_num, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"PatternSearch",tElapsed);

    %% Simulated Annealing
    [best_params(5,i,k,:), fval(5,i,k), tElapsed(5,i,k)]= run_simulatedAnnealingContRC(DataSystem, VarSystem, x0_matr(i,:), lb, ub, numStarts);
    % [fig, plot_num] = plotParam(fig, plot_num, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"Simulated Annealing",tElapsed);

    %% Surrogate 
    [best_params(6,i,k,:),fval(6,i,k),tElapsed(6,i,k)] = run_surrogateContRC(DataSystem, VarSystem, lb, ub, numStarts);
    % [fig, plot_num] = plotParam(fig, plot_num, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,"Surrogate",tElapsed);
        end
    end

    save("best_params_stat1","best_params");
    save("fval1","fval");
    save("tElapsed1","tElapsed");
    load("best_params_stat1","best_params");
    load("fval1","fval");
    load("tElapsed1","tElapsed");

    % x_mat = (1:length(x0_matr))'*ones(1,10);
    x_mat = (squeeze(x0_matr(:,1)))*ones(1,10);
    figure()
    scatter(x_mat, squeeze(fval(1, :, :)))
else
    warning('Uncorrect opt mod');
end



function [fig, plot_num] = plotParam(fig, plot_num, x0, VarSystem, DataSystem, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,name,tElapsed)
    if(isempty(fig) || isempty(plot_num))
        plot_num = 1;
    end
    fig = [fig figure()];

surf(ResistanceBEGrid, ResistanceBGrid, lambda_surface.lambda_surface,'EdgeColor','none', 'FaceAlpha', 0.5);

xlabel('X: Resistance_{be} (Ω)');
ylabel('Y: Resistance_{b} (Ω)');
zlabel('Z: Lambda (Failure Rate)');
title(' ');
colorbar; % Добавляем цветовую панель для обозначения значений lambda

    hold on 
    sc = scatter3(best_params(1),best_params(2),fval,'red','square','filled','SizeData',400); 
    dt=datatip(sc);
    % min(min(lambda_surface.lambda_surface)

    % Создаем матрицу размером 70x70 с одинаковыми строками
matrixString = strings(height(ResistanceBGrid), width(ResistanceBGrid));

% Заполняем матрицу одинаковым элементом
matrixString(:) = name; % замените "element" на желаемое 

aa = dataTipTextRow('label',matrixString);
sc.DataTipTemplate.DataTipRows(end+1) = aa;

    
    sc = scatter3(ResistanceBEGrid(row,col),ResistanceBGrid(row,col),lambda_surface.lambda_surface(row,col),'green','square','filled','SizeData',400); 
    dt=datatip(sc);
% % % 
% % % 
% Заполняем матрицу одинаковым элементом
matrixString1 = strings(height(ResistanceBGrid), width(ResistanceBGrid));
matrixString1(:) = 'x_0'; % замените "element" на желаемое 

sc1 = scatter3(x0(1),x0(2),getFunctionSystemUnoCont(x0, DataSystem, VarSystem),'magenta','square','filled','SizeData',400); 
bb = dataTipTextRow('label',matrixString1);
sc1.DataTipTemplate.DataTipRows(end+1) = bb;

    

    dt1=datatip(sc1);
% % % 
% % % 
% Заполняем матрицу одинаковым элементом
matrixString(:) = "TrueMinimum"; % замените "element" на желаемое 

aa = dataTipTextRow('label',matrixString);
sc.DataTipTemplate.DataTipRows(end+1) = aa;
    
    plot_num = plot_num + 1;
    hold off




    % Specify the Excel file name
filename = 'your_excel_file.xlsx'; % Replace 'your_excel_file.xlsx' with your actual file name

% Read the existing Excel file into a table
try
    existingData = readtable(filename);
catch
    existingData = [];
end

% Создайте структуру для нового значения
mstr = struct( ...
   'name', name, ...
   'best_params_1', best_params(1), ...
   'best_params_2', best_params(2), ...
   'fval', fval, ...
   'absError', lambda_surface.lambda_surface(row,col)-fval,...
   'tElapsed', tElapsed ...
);

% Преобразуйте структуру в таблицу
newTable = struct2table(mstr);

% Теперь попробуйте объединить таблицы
combinedData = [existingData; newTable];

% % 
% % 
% % 
% traektory
hold on
global drawing;
plot3(drawing.x(:,1), drawing.x(:,2), drawing.f(:,1),'Color','k','Marker','.','MarkerSize',20);
hold off
% Write the combined data back to the Excel file
try
    writetable(combinedData, filename, 'Sheet',1); % Writes to the first sheet. Change 'Sheet',1 to specify other sheets if needed.
catch
    error('Error writing the table to Excel file.  Make sure the file is not open in another application.');
end

disp('Table appended successfully!');
clear_drawing();
end

function clear_drawing()
global drawing;
drawing.f = []; % Инициализация массива f
drawing.x = []; % Инициализация массива x
end

