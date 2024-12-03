function [lambda] = getReliabilitySystemFromData(DataSystem,...
    IteratorCapacitor, IteratorDiod, IteratorResistor_B, IteratorResistor_K, IteratorTransistor,...
    t, capacity, U_ratio, iRelative, power_b, resistance_b, P_ratio_b,...
    power_k, resistance_k, P_ratio_k, pRelative, s1)

    % Capacitor
    lambda_Capacitor = getReliabilityCapacitorFromData(...
        DataSystem.Capacitor, IteratorCapacitor,capacity, U_ratio, t);

    % Diod
    lambda_Diod = getReliabilityDiodFromData(...
        DataSystem.Diod, IteratorDiod, iRelative, t);

    % Resistor_B
    lambda_Resistor_B = getReliabilityResistorFromData(...
        DataSystem.Resistor, IteratorResistor_B, power_b, resistance_b, P_ratio_b, t);

    % Resistor_K
    lambda_Resistor_K = getReliabilityResistorFromData(...
        DataSystem.Resistor, IteratorResistor_K, power_k, resistance_k, P_ratio_k, t);

    % Transistor
    lambda_Transistor = getReliabilityTransistorFromData(...
        DataSystem.Transistor, IteratorTransistor, pRelative, t, s1);
    
    % System
    lambda = lambda_Capacitor*2 + lambda_Diod*2 + lambda_Resistor_B*2 + lambda_Resistor_K*2 + lambda_Transistor*2;

%% Var and Param
    % % Capacitor
    % capacity  % In picoPharad
    % U_ratio   % 0 to 1
    % t         % In degC
    
    % % Diod
    % iRelative % 0 to 1
    
    % % Resistor B 
    % power_b   % Whatt
    % resistance_b % In Ohm
    % P_ratio_b % 0 to 1
    
    % % Resistor K
    % power_k   % Whatt
    % resistance_k  % In Ohm
    % P_ratio_k % 0 to 1
    
    % % Transistor
    % pRelative % 0 to 1
    % s1        % 0 to 1

end