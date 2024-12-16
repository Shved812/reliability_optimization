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

%%
[DataSystem] = getTableSystemData(FilenameSystem);

VarSystem.IteratorCapacitor   = 1;
VarSystem.IteratorDiod        = 1;
VarSystem.IteratorResistor_B  = 20;
VarSystem.IteratorResistor_K  = 1;
VarSystem.IteratorTransistor  = 1;
VarSystem.t   = 30;
VarSystem.capacity    = 1000e-12;
VarSystem.U_ratio     = 1/2;
VarSystem.iRelative   = 1/2;
VarSystem.power_b     = 0.5;
VarSystem.resistance_b= 200;
VarSystem.P_ratio_b   = 1/2;
VarSystem.power_k     = 0.5;
VarSystem.resistance_k = 200;
VarSystem.P_ratio_k   = 1/2;
VarSystem.pRelative   = 1/2;
VarSystem.s1  = 1/2;
VarSystem.goalfreq  = 1000;
% 

Transistor_struct = DataSystem.Transistor;
%% K_p
    % % get coef ->
    % t=25:1:85;
    % P_ratio=0.1:0.1:1;
    % for k = 1:length(P_ratio)
    %     point(k).P_ratio(k)=P_ratio(k);
    %     for i = 1:length(t)
    %         [lambdaB, kPr, kR, kF, kS1, kE] = getCoefTransistorFromData(DataSystem.Transistor, VarSystem.IteratorTransistor, P_ratio(k), t(i), VarSystem.s1);
    % 
    %         point(k).t(i)=t(i);
    %         point(k).lambdaB(i)=lambdaB;
    %         point(k).kPr(i)=kPr;
    %         point(k).kR(i)=kR;
    %         point(k).kF(i)=kF;
    %         point(k).kS1(i)=kS1;
    %         point(k).kE(i)=kE;
    %     end
    % end
    % figure
    % for k = 1:length(P_ratio)
    %     plot(point(k).t,point(k).kR)
    %     hold on
    % end
    % 
    % figure
    % [X,Y] = meshgrid(t,P_ratio);
    % for k = 1:length(P_ratio)
    %     Z(k,:) = point(k).kR; 
    % end
    % surf(X,Y,Z,'EdgeColor','none')
    % colorbar
    % colormap('cool')
    % xlabel('T, ℃')
    % ylabel('P/P_н')
    % zlabel('K_p')
    % hold on
    % fimplicit3(@(x1,x2,K_p) K_p-1,[t(1) t(end) P_ratio(1) P_ratio(end) min(min(Z)) max(max(Z))],'FaceAlpha',0.1,'EdgeColor','r')
    % legend('K_p(T,P/P_н)','K_p = 1')
%% K_S1
% figure;
% 
% U_ratio = 0:0.001:1; % Резисторы
% point = struct(); % Инициализация структуры
% 
% % Получаем коэффициенты для каждого R
% for i = 1:length(U_ratio)
%             [lambdaB, kPr, kR, kF, kS1, kE] = getCoefTransistorFromData(DataSystem.Transistor, VarSystem.IteratorTransistor, VarSystem.pRelative, VarSystem.t, U_ratio(i));
% 
%             % point.t(i)=t(i);
%             point.lambdaB(i)=lambdaB;
%             point.kPr(i)=kPr;
%             point.kR(i)=kR;
%             point.kF(i)=kF;
%             point.kS1(i)=kS1;
%             point.kE(i)=kE;
% end
% 
% % Вытаскиваем K_S для всех точек
% K_S1_values = [point.kS1];
% 
% % Строим график
% plot(U_ratio, K_S1_values, 'LineWidth', 2, 'Color', 'k'); % Синяя линия
% grid on; % Включаем сетку
% 
% % Добавляем заголовок и подписи
% title('Зависимость K_S от S', 'FontSize', 14);
% xlabel('Нагрузка по напряжению S', 'FontSize', 12);
% ylabel('Коэффициент K_S', 'FontSize', 12);
% 
% % Добавляем легенду
% legend('K_S', 'Location', 'Best');
% 
% % Настройка осей
% xlim([min(U_ratio) max(U_ratio)]);
% ylim([min(K_S1_values) max(K_S1_values)]);
% 
% % Дополнительные настройки
% set(gca, 'FontSize', 12); % Установка размера шрифта
%% lambda2
figure;

point = struct(); % Инициализация структуры
t=25:1:85;
P_ratio=0.1:0.1:1;
% leg_cell = [];
% [num, partName, type, groupKey, technicalConditions, tTrMax, tLow, lambdaB] = getTableTransistor(DataSystem.Transistor, VarSystem.IteratorTransistor);
for k = 1:length(P_ratio)
% Получаем коэффициенты для каждого R
    for i = 1:length(t)
        lambda = getReliabilityTransistorFromData(DataSystem.Transistor, VarSystem.IteratorTransistor, P_ratio(k), t(i), VarSystem.s1);
        
        point(k).t(i)= t(i);
        point(k).lambda(i) = lambda;
        leg_cell(k) = {"P/P_н = " + num2str(P_ratio(k))};
    end
end

% Вытаскиваем K_R для всех точек
% lambda = [point.lambda];

% Строим график
    % figure
    for k = 1:length(P_ratio)
        plot(point(k).t,point(k).lambda, 'LineWidth', 2)
        hold on
    end
grid on; % Включаем сетку

% Добавляем заголовок и подписи
title('Зависимость \lambda_э от t', 'FontSize', 14);
xlabel('T, ℃', 'FontSize', 12);
ylabel('\lambda_э', 'FontSize', 12);

% % Добавляем легенду
% legend('\lambda_э');
legend(leg_cell, 'Location', 'Best')

% Настройка осей
xlim([min(t) max(t)]);
% ylim([min(lambda) max(lambda)]);

% Дополнительные настройки
set(gca, 'FontSize', 12); % Установка размера шрифта
% 
% 
% 


    figure
    [X,Y] = meshgrid(t,P_ratio);
    for k = 1:length(P_ratio)
        Z(k,:) = point(k).lambda; 
    end
    surf(X,Y,Z,'EdgeColor','none')
    colorbar
    colormap('cool')
    xlabel('T, ℃')
    ylabel('P/P_н')
    zlabel('lambda')
    % hold on
    % fimplicit3(@(x1,x2,lambda) lambda-1,[t(1) t(end) P_ratio(1) P_ratio(end) min(min(Z)) max(max(Z))],'FaceAlpha',0.1,'EdgeColor','r')
    % legend('lambda(T,P/P_н)','lambda = 1')
    legend('lambda(T,P/P_н)')
    %% lambda3
figure(1);

point = struct(); % Инициализация структуры
t=25:1:85;
P_ratio=0.1:0.1:1;
% leg_cell = [];

% [num, partName, type, groupKey, technicalConditions, tTrMax, tLow, lambdaB] = getCoefTransistorFromData(DataSystem.Transistor, VarSystem.IteratorTransistor);
for k = 1:length(P_ratio)
% Получаем коэффициенты для каждого R
    for i = 1:length(t)
        [lambdaB, kPr, kR, kF, kS1, kE] = getCoefTransistorFromData(DataSystem.Transistor, VarSystem.IteratorTransistor, P_ratio(k), t(i), VarSystem.s1);
        
        point(k).t(i)= t(i);
        point(k).lambda(i) = lambdaB;
        leg_cell(k) = {"P/P_н = " + num2str(P_ratio(k))};
    end
end

% Вытаскиваем K_R для всех точек
% lambda = [point.lambda];

% Строим график
    % figure
    % for k = 1:length(P_ratio)
        plot(point(1).t,point(1).lambda, 'LineWidth', 2,'LineStyle','--','Color','r')
        hold on
    % end
grid on; % Включаем сетку

% Добавляем заголовок и подписи
title('Зависимость \lambda_э от t', 'FontSize', 14);
xlabel('T, ℃', 'FontSize', 12);
ylabel('\lambda_э', 'FontSize', 12);

% % Добавляем легенду
% legend('\lambda_э');
% legend(leg_cell, 'Location', 'Best')

% Настройка осей
xlim([min(t) max(t)]);
% ylim([min(lambda) max(lambda)]);

% Дополнительные настройки
set(gca, 'FontSize', 12); % Установка размера шрифта
% 
% 
% 
legend([leg_cell,{"\lambda_э = \lambda_b^'"}], 'Location', 'Best')

    figure
    [X,Y] = meshgrid(t,P_ratio);
    for k = 1:length(P_ratio)
        Z(k,:) = point(k).lambda; 
    end
    surf(X,Y,Z,'EdgeColor','none')
    colorbar
    colormap('cool')
    xlabel('T, ℃')
    ylabel('P/P_н')
    zlabel('lambda')
    % hold on
    % fimplicit3(@(x1,x2,lambda) lambda-1,[t(1) t(end) P_ratio(1) P_ratio(end) min(min(Z)) max(max(Z))],'FaceAlpha',0.1,'EdgeColor','r')
    % legend('lambda(T,P/P_н)','lambda = 1')
    legend('lambda(T,P/P_н)')