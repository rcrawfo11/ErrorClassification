function [ struct ] = fitColeColeModel(frequencies, magPhase, varargin )
%function [ struct ] = fitColeColeModel( frequencies, magPhase, [type],[plot],[strayComp],[titlename] )

if (nargin == 2)
    model = 'mag';
    plot = 1;
    strayComp = 0;
    titleName = 'Fit';
elseif (nargin == 3)
    model = varargin{1};
    plot = 1;
    strayComp = 0;
    titleName = 'Fit';
elseif (nargin == 4)
    model = varargin{1};
    plot = varargin{2};
    strayComp = 0;
    titleName = 'Fit';
elseif (nargin == 5)
    model = varargin{1};
    plot = varargin{2};
    strayComp = varargin{3};
    titleName = 'Fit';
else
    model = varargin{1};
    plot = varargin{2};
    strayComp = varargin{3};
    titleName = varargin{4};
end

magPhaseOrig = magPhase;

% if necessary, apply stray compensation
if (strayComp)
        aLen = length(frequencies);
        susceptance = imag(1./magPhase2impedance(magPhase));
        
        % Calculate Cpar (could use last 3 pts instead?)
        Cpar = (susceptance(aLen) - susceptance(aLen - 1))/(2*pi*(frequencies(aLen) - frequencies(aLen -1)));
        Zfit = magPhase2impedance(magPhase);
        Zcorr = 1./(1 - (1i*2*pi.*frequencies.*Cpar.*Zfit));
        Zcorrected = Zfit.*Zcorr;
        magPhaseComp = impedance2magPhase(Zcorrected);
        realImagComp = magPhase2realImag(magPhaseComp);
end

realImag = magPhase2realImag(magPhase);

switch model
    
    case {'magnitude','mag'}
        X = frequencies; % frequencies
        y = magPhase(1,:); % magnitude of impedance
        
        

        % Rinf + (R0 - Rinf)/(1+(jwtau)^alpha)
        % [R0 Rinf tau alpha]
        % [1   2    3    4  ]

        % model based on magnitude
        modelfun = @(b,x)abs(b(2) + (b(1) - b(2))./(1 + (1i * 2 * pi .* x .* b(3)) .^b(4)));
        %beta0 = [600 400 1/(100e3*2*pi) 0.7];
        beta0 = [60 20 1/(50e3*2*pi) 0.8];
        %beta0 = [15e4 2e4 2.88e-6 0.835];
        mdl = fitnlm(X,y,modelfun,beta0);
        coefficients = mdl.Coefficients.Estimate;
        
        if (strayComp)
            ycomp = magPhaseComp(1,:);
            mdlComp = NonLinearModel.fit(X,ycomp,modelfun,beta0);
            coefficientsComp = mdlComp.Coefficients.Estimate;
        end
    
    case 'magStray'
        X = frequencies; % frequencies
        y = magPhase(1,:); % magnitude of impedance
        % Zbody = Rinf + (R0 - Rinf)/(1+(jwtau)^alpha)
        % Ztotal = Zbody * 1/(s*Zbody*Cstray + 1)
        
        modelfun = @(b,x)abs((b(2) + (b(1) - b(2))./(1 + (1i * 2 * pi .* x .* b(3)) .^b(4))).*(1/1i * 2 * pi .* x .* b(5) .* (b(2) + (b(1) - b(2))./(1 + (1i * 2 * pi .* x .* b(3)) .^b(4)))+1));
        beta0 = [600 400 1/(100e3*2*pi) 0.7 100e-12];
        mdl = NonLinearModel.fit(X,y,modelfun,beta0);
        coefficients = mdl.Coefficients.Estimate;
        
    case 'phsStray'
        X = frequencies; % frequencies
        y = magPhase(2,:); % phase of impedance
        % Zbody = Rinf + (R0 - Rinf)/(1+(jwtau)^alpha)
        % Ztotal = Zbody * 1/(s*Zbody*Cstray + 1)
        modelfun = @(b,x)rad2deg(angle((b(2) + (b(1) - b(2))./(1 + (1i * 2 * pi .* x .* b(3)) .^b(4))).*(1/1i * 2 * pi .* x .* b(5) .* (b(2) + (b(1) - b(2))./(1 + (1i * 2 * pi .* x .* b(3)) .^b(4)))+1)));
        beta0 = [600 400 1/(100e3*2*pi) 0.7 100e-12];
        mdl = NonLinearModel.fit(X,y,modelfun,beta0);
        coefficients = mdl.Coefficients.Estimate;
        
    case 'real'
        X = frequencies; % frequencies
        realImag = magPhase2realImag(magPhase);
        y = realImag(1,:); % real part of impedance
        
        % Rinf + (R0 - Rinf)/(1+(jwtau)^alpha)
        % [R0 Rinf tau alpha]
        % [1   2    3    4  ]

        % model based on real part
        modelfun = @(b,x)real(b(2) + (b(1) - b(2))./(1 + (1i * 2 * pi .* x .* b(3)) .^b(4)));
        beta0 = [600 400 1/(100e3*2*pi) 0.7];
        mdl = NonLinearModel.fit(X,y,modelfun,beta0);
        coefficients = mdl.Coefficients.Estimate;
        
        if (strayComp)
            ycomp = realImagComp(1,:);
            mdlComp = NonLinearModel.fit(X,ycomp,modelfun,beta0);
            coefficientsComp = mdlComp.Coefficients.Estimate;
        end
        
    case {'imag','reactance'}
        X = frequencies; % frequencies
        realImag = magPhase2realImag(magPhase);
        y = realImag(2,:); % imag part of impedance
        
        % Rinf + (R0 - Rinf)/(1+(jwtau)^alpha)
        % [R0 Rinf tau alpha]
        % [1   2    3    4  ]

        % model based on imag part
        modelfun = @(b,x)imag(b(2) + (b(1) - b(2))./(1 + (1i * 2 * pi .* x .* b(3)) .^b(4)));
        beta0 = [400 200 4.5e-6 1];
        mdl = NonLinearModel.fit(X,y,modelfun,beta0);
        coefficients = mdl.Coefficients.Estimate;
        
        if (strayComp)
            ycomp = realImagComp(2,:);
            mdlComp = NonLinearModel.fit(X,ycomp,modelfun,beta0);
            coefficientsComp = mdlComp.Coefficients.Estimate;
        end
        

    case {'circle','realImag','quad'}
        % don't return a model, maybe later add error calculation ability?
        mdl = 0;
        
        coefficients = circleFit( frequencies, magPhase );
        if (strayComp)
            mdlComp = 0;
            coefficientsComp = circleFit( frequencies, magPhaseComp );
        end
end

    modelStruct = generateBodyModelAlpha(frequencies,coefficients(1),coefficients(2),abs(coefficients(3)),coefficients(4),0);
    magPhaseEst = modelStruct.magPhase;
    realImagEst = modelStruct.realImag;
    
    if (strayComp)
        modelStructComp = generateBodyModelAlpha(frequencies,coefficientsComp(1),coefficientsComp(2),abs(coefficientsComp(3)),coefficientsComp(4),0);
        magPhaseEstComp = modelStructComp.magPhase;
        realImagEstComp = modelStructComp.realImag;
    end
    
    struct.frequencies = frequencies;
    struct.magPhaseOrig = magPhaseOrig;
    struct.realImagOrig = magPhase2realImag(magPhaseOrig);
    struct.coeffs = coefficients;
    struct.mdl = mdl;
    struct.type = model;
    struct.strayComp = strayComp;
    struct.magPhaseEst = magPhaseEst;
    struct.realImagEst = realImagEst;
    struct.alpha = coefficients(4);
    
    if (isfield(mdl,'RMSE'))
        %struct.RMSE = mdl.RMSE;
        struct.RMSE = rmseFitCircle( realImag(1,:), realImag(2,:), realImagEst(1,:), realImagEst(2,:));
    else
        struct.RMSE = rmseFitCircle( realImag(1,:), realImag(2,:), realImagEst(1,:), realImagEst(2,:));
    end
    
    struct.Re = coefficients(1); % Re is R0
    struct.Ri = rinf2ri(struct.Re,coefficients(2));
    struct.Cm = coefficients(3) / (struct.Re + struct.Ri);
    
    if (strayComp) 
        struct.CparEst = Cpar; 
        struct.magPhaseComp = magPhaseComp;
        struct.realImagComp = magPhase2realImag(magPhaseComp);
        struct.mdlComp = mdlComp;
        struct.coeffsComp = coefficientsComp;
        struct.magPhaseEstComp = magPhaseEstComp;
        struct.realImagEstComp = realImagEstComp;
        struct.alphaComp = coefficientsComp(4);
        
        if (isfield(mdlComp,'RMSE'))
            struct.RMSEComp = mdlcomp.RMSE;
            struct.RMSEComp = rmseFitCircle( realImagComp(1,:), realImagComp(2,:), realImagEstComp(1,:), realImagEstComp(2,:));
        else
            struct.RMSEComp = rmseFitCircle( realImagComp(1,:), realImagComp(2,:), realImagEstComp(1,:), realImagEstComp(2,:));
        end
        
        struct.ReComp = coefficientsComp(1); % Re is R0
        struct.RiComp = rinf2ri(struct.Re,coefficientsComp(2));
        struct.CmComp = coefficientsComp(3) / (struct.ReComp + struct.RiComp);
    end
    
    if (plot)
        figure
        plotByCase(struct,'magPhaseFit',titleName);
        figure
        plotByCase(struct,'realImagFit',titleName);
    end

end

