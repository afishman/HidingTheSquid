%%%%%Find steady state
function [lambdaAct, lambdaUni]=findSS(nElemOn, obj)
% %Write lambda1 here once you find it and rerun
% lambda1 = 5.02;



%%%%Main Routiune
%THe number of elements that are on
nElemOff = obj.nElem - nElemOn;

%Important info
theLength = obj.theLength;
L = obj.L;

%The sum of the stretch ratios
sumOfStretch = obj.preStretch*obj.nElem;

%Lamnda_U as a function of lambda_1
lambdaU = @(lambda) (sumOfStretch - nElemOn.*lambda)./nElemOff;

%%%%Sigma Mat function
muA=obj.muA; muB=obj.muB; Ja=obj.Ja; Jb=obj.Jb;
sigmaMat = @(lambda, xi) ...
    (muA*(lambda.^2 - lambda.^-4))./...
    (1 - (2*lambda.^2 + lambda.^-4 - 3)./Ja)...
    + ...
    (muB*(lambda.^2.*xi.^-2 - lambda.^-4.*xi.^4))./...
    (1 - (2*lambda.^2.*xi.^-2 + lambda.^-4.*xi.^4)./Jb);

%%%%Sigma Elec Function
eRel = obj.eRel; T = obj.T; V = obj.Vs;
%Electrical Stress
sigmaElec = @(lambda,V) eRel * V.^2 * T^-2 .* lambda.^4;

%%%%Function to solve for roots for
f = @(lambda)...
    (sigmaElec(lambda,V) - sigmaMat(lambda,lambda)).*lambda.^-1 +...
    sigmaMat(lambdaU(lambda), lambdaU(lambda)).*lambdaU(lambda).^-1;




%%%%Perform calculations
%The List
x = linspace(1,6,1000);

y = f(x);
save debug
% % Plot
% close all
% plot(x,y)
% grid on
% 
% 
lambdaAct=fzero(f, 5.1);

lambdaUni=lambdaU(lambdaAct);