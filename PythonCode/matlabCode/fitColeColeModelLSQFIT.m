% lsqcurvefit attempts to solve problems of the form:
%     min  sum {(FUN(X,XDATA)-YDATA).^2}  where X, XDATA, YDATA and the
%      X                                  values returned by FUN can be 
%                                         vectors or matrices.
%  
%     lsqcurvefit implements two different algorithms: trust region reflective and 
%     Levenberg-Marquardt. Choose one via the option Algorithm: for instance, to 
%     choose Levenberg-Marquardt, set 
%     OPTIONS = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt'), 
%     and then pass OPTIONS to lsqcurvefit.  
%  
%     X = lsqcurvefit(FUN,X0,XDATA,YDATA) starts at X0 and finds coefficients
%     X to best fit the nonlinear functions in FUN to the data YDATA (in the 
%     least-squares sense). FUN accepts inputs X and XDATA and returns a
%     vector (or matrix) of function values F, where F is the same size as
%     YDATA, evaluated at X and XDATA. NOTE: FUN should return FUN(X,XDATA)
%     and not the sum-of-squares sum((FUN(X,XDATA)-YDATA).^2).
%     ((FUN(X,XDATA)-YDATA) is squared and summed implicitly in the
%     algorithm.) 
% X = lsqcurvefit(FUN,X0,XDATA,YDATA,LB,UB) defines a set of lower and
%     upper bounds on the design variables, X, so that the solution is in the
%     range LB <= X <= UB. Use empty matrices for LB and UB if no bounds
%     exist. Set LB(i) = -Inf if X(i) is unbounded below; set UB(i) = Inf if
%     X(i) is unbounded above.

function [ struct ] = fitColeColeModelLSQFIT(frequencies, magPhase, plotBool,titleName,realBool)

% backward compatibility
if nargin < 5
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

XDATA = frequencies; % input is the frequency
YDATA = magPhase(1,:); % output is the magnitude of the function
LB = [10,10,1/(80e3*2*pi),0.65]; % lower bounds
UB = [100,100,1/(20e3*2*pi),1]; % upper bounds

%options = optimset('MaxFunEvals',1000,'TolFun',1e-15,'TolX',1e-15);
%options = optimset('MaxFunEvals',50);
[X,resnorm,residual,exitflag,output] = lsqcurvefit(FUN,X0,XDATA,YDATA,LB,UB);%,options);

struct.fit = X;
struct.resnorm = resnorm;
struct.resnormNorm = resnorm/numel(frequencies)/X(1); % normalize by number of frequencies and Re
struct.residual = residual;
struct.exitflag = exitflag;
struct.output = output;

struct.frequencies = frequencies;
struct.magPhaseOrig = magPhase;
est = generateBodyModelAlpha(frequencies,X(1),X(2),X(3),X(4),0);
struct.magPhaseEst = est.magPhase;
struct.strayComp = 0;

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


