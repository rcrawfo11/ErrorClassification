function [ struct ] = fitColeColeModelMultiStart( frequencies, magPhase, plotBool,titleName, realBool )
%function [ struct ] = fitColeColeModelMultiStart( frequencies, magPhase, plotBool,titleName )
%   Detailed explanation goes here

% backwards compatability 
if (nargin < 5)
    realBool = 0;
end

% Rinf + (R0 - Rinf)/(1+(jwtau)^alpha)
% [R0 Rinf tau alpha]
% [1   2    3    4  ]
if realBool
    FUN = @(X,XDATA)real(X(2) + (X(1) - X(2))./(1 + (1i * 2 * pi .* XDATA .* X(3)) .^X(4)));
else
    FUN = @(X,XDATA)abs(X(2) + (X(1) - X(2))./(1 + (1i * 2 * pi .* XDATA .* X(3)) .^X(4)));
end

X0 = [60 20 1/(50e3*2*pi) 0.8]; % starting values for calf measurement

xdata = frequencies; % input is the frequency
ydata = magPhase(1,:); % output is the magnitude of the function
lb = [10,10,1/(80e3*2*pi),0.65]; % lower bounds
ub = [100,100,1/(20e3*2*pi),1]; % upper bounds

problem = createOptimProblem('lsqcurvefit','x0',X0,'objective',FUN,...
    'lb',lb,'ub',ub,'xdata',xdata,'ydata',ydata);

ms = MultiStart();
%ms = MultiStart('PlotFcns',@gsplotbestf);
%[X,errormulti] = run(ms,problem,50);
[X,errormulti,exitflag,output,solutions] = run(ms,problem,50);

struct.fit = X;
struct.frequencies = frequencies;
struct.magPhaseOrig = magPhase;
est = generateBodyModelAlpha(frequencies,X(1),X(2),X(3),X(4),0);
struct.magPhaseEst = est.magPhase;
struct.strayComp = 0;
struct.errorMulti = errormulti;
struct.errorPercMean = calculateResidualErrorPercent(magPhase,est.magPhase);

struct.Re = X(1);
struct.Ri = rinf2ri(struct.Re,X(2));
struct.Rinf = X(2);
struct.Cm = X(3) / (struct.Re + struct.Ri);
struct.alpha = X(4); 

 if (plotBool)
     figure
     plotByCase(struct,'magPhaseFit',titleName);
     %figure
     %plotByCase(struct,'realImagFit',titleName);
 end
end

