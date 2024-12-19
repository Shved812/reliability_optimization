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
%% prototype
% [lambda] = getReliabilitySystemFromData(DataSystem, VarSystem)
%%
[DataSystem] = getTableSystemData(FilenameSystem);

[VarSystem] = getVarSystem();
%% optimization
lb = [1 1e3]; 
ub = [225-1 .5e6]; 
x0 = [1 1];
numVar = 2;
plot_num = [];
fig = [];
numStarts = 100; 
%% строить поверхность долго
% Задаем диапазоны значений для capacity и resistance_k
resistance_range = linspace(lb(2),ub(2),100);
transistor_range = lb(1):ub(1);

% Создаем сетку значений
[TransitorGrid, ResistanceGrid] = meshgrid(transistor_range,resistance_range);

% % Предварительно создаем матрицу для хранения результатов
% lambda_surface = zeros(size(TransitorGrid));
% 
% % Вычисляем lambda для каждой комбинации capacity и resistance_k
% for i = 1:size(TransitorGrid, 1)
%     for j = 1:size(TransitorGrid, 2)
%         [VarSystem] = getVarSystemVariable(VarSystem.IteratorCapacitor, VarSystem.IteratorDiod, VarSystem.IteratorResistor_B, VarSystem.IteratorResistor_BE,...
%     VarSystem.IteratorResistor_E, TransitorGrid(i,j), VarSystem.t, VarSystem.capacity,...
%     ResistanceGrid(i,j),ResistanceGrid(i,j), VarSystem.resistance_E, VarSystem.goalfreq)
%         lambda_surface(i, j) = getReliabilitySystemFromData(DataSystem, VarSystem);
%     end
% end
% save("lambda3","lambda_surface")
lambda_surface = load("lambda3","lambda_surface");
% Построение 3D поверхности
figure;
surf(TransitorGrid, ResistanceGrid, lambda_surface.lambda_surface,'EdgeColor','none');
% scatter3(ResistanceGrid, TransitorGrid, lambda_surface.lambda_surface,'black','filled');
%%
% Находим минимальное значение в матрице и его индекс
[minValue, linearIndex] = min(lambda_surface.lambda_surface(:));

% Преобразуем линейный индекс в двумерные индексы (строка и столбец)
[row, col] = ind2sub(size(lambda_surface.lambda_surface), linearIndex)
hold on
sc = scatter3(TransitorGrid(row,col),ResistanceGrid(row,col),lambda_surface.lambda_surface(row,col),'red','square','filled','SizeData',200); 
dt=datatip(sc);
% Задаем размер матрицы

% Создаем матрицу размером 70x70 с одинаковыми строками
matrixString = strings(height(TransitorGrid), width(ResistanceGrid));

% Заполняем матрицу одинаковым элементом
matrixString(:) = "TrueMinimum"; % замените "element" на желаемое 

aa = dataTipTextRow('label',matrixString);
sc.DataTipTemplate.DataTipRows(end+1) = aa;

hold off
xlabel('X: Resistance (Ω)');
ylabel('Y: Transistor_{index}');
zlabel('Z: Lambda (Failure Rate)');
title(' ');
colorbar
% colormap('copper')
%% Genetic 
[best_params,fval,tElapsed] = run_geneticMixed(DataSystem, VarSystem, x0, lb, ub, numVar,numStarts) 
[fig, plot_num] = plotParam(fig, plot_num, best_params, fval, lambda_surface, TransitorGrid, ResistanceGrid,row,col,"Genetic",tElapsed);
%% Surrogate 
[best_params, fval, tElapsed] = run_surrogateoptMixed(DataSystem,VarSystem, lb, ub, numVar,numStarts)  
[fig, plot_num] = plotParam(fig, plot_num, best_params, fval, lambda_surface, TransitorGrid, ResistanceGrid,row,col,"Surrogate",tElapsed);

 function [fig, num] = plotParam(fig, num, best_params, fval, lambda_surface, ResistanceBEGrid, ResistanceBGrid,row,col,name,tElapsed)
    if(isempty(fig) || isempty(num))
        num = 1;
    end
    fig = [fig figure()];

surf(ResistanceBEGrid, ResistanceBGrid, lambda_surface.lambda_surface,'EdgeColor','none');

xlabel('X: Resistance (Ω)');
ylabel('Y: Transistor_{index}');
zlabel('Z: Lambda (Failure Rate)');
title(' ');
colorbar; % Добавляем цветовую панель для обозначения значений lambda

    hold on 
    sc = scatter3(best_params(1),best_params(2),fval,'red','square','filled','SizeData',200); 
    dt=datatip(sc);
    % min(min(lambda_surface.lambda_surface)

    % Создаем матрицу размером 70x70 с одинаковыми строками
matrixString = strings(height(ResistanceBGrid), width(ResistanceBGrid));

% Заполняем матрицу одинаковым элементом
matrixString(:) = name; % замените "element" на желаемое 

aa = dataTipTextRow('label',matrixString);
sc.DataTipTemplate.DataTipRows(end+1) = aa;

    
    sc = scatter3(ResistanceBEGrid(row,col),ResistanceBGrid(row,col),lambda_surface.lambda_surface(row,col),'green','square','filled','SizeData',200); 
    dt=datatip(sc);


% Заполняем матрицу одинаковым элементом
matrixString(:) = "TrueMinimum"; % замените "element" на желаемое 

aa = dataTipTextRow('label',matrixString);
sc.DataTipTemplate.DataTipRows(end+1) = aa;
    
    num = num + 1;
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



% Write the combined data back to the Excel file
try
    writetable(combinedData, filename, 'Sheet',1); % Writes to the first sheet. Change 'Sheet',1 to specify other sheets if needed.
catch
    error('Error writing the table to Excel file.  Make sure the file is not open in another application.');
end

disp('Table appended successfully!');

end