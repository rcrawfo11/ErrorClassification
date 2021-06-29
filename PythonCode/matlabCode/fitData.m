frequencies = logspace(4,5.7,51);
Re = 500;
Ri = 1000;
Cm = 2e-9;

[magphase, realImag] = generateBodyModel(frequencies,Re,Ri,Cm);

X = frequencies; % frequencies
y = magphase(1,:);% impedance
% [Rinf Ro tau alpha]
%modelfun = @(b,x)abs(b(1) + (b(2) - b(1))./(1+(1i*2*pi.*x.*b(3)).^(b(4))));
%beta0 = [500 350 100e3 1];% best guess values

% [Re Ri Cm]
% Re * (Ri + 1/(s*Cm)) / (Re + Ri + 1/(s*Cm));
modelfun = @(b,x)abs((b(1).*(1+1i*2*pi.*x.*b(2).*b(3)))./(1+1i*2*pi.*x.*(b(1)+b(2)).*b(3)));
beta0 = [400 800 1e-9];
mdl = NonLinearModel.fit(X,y,modelfun,beta0);
coefficients = mdl.Coefficients.Estimate;