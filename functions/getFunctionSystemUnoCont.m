function F = getFunctionSystemUnoCont(x, DataSystem, VarSystem)

    VarSystem.resistance_BE = x(1);
    VarSystem.resistance_B = x(2);

    F = getReliabilitySystemFromData(DataSystem, VarSystem);  
    global drawing;
    % Проверяем, что можно добавить элементы
    drawing.f(end+1,1) = F; % Добавление нового элемента в массив f
    
    % Добавление массива x
    drawing.x = [drawing.x; x]; % Используем вертикальную конкатенацию, если x - строка
end
