function [kR] = getCoefDiod_kR(iRelative, t)
	% для излучателей в зависимости от типа полупроводникового излучающего материала:
	% m = 1,4 – для GаАs;
	% m = 1,2 – для GаР;
	% m = 1,5 – для GаАlАs; GаАsР.
	% При работе в импульсном режиме m = 2.

    Ea = 0.6;
    k = 8.625*1e-5;
    m = 1.5; % 2

    tp = t + iRelative*20;
    tn = 25;    % tn - нормальная температура окружающей среды
    tp0 = tn + 20;

    kR = (iRelative)^m*exp(Ea/k*(1/(tp0 + 273) - 1/(tp + 273)));
end