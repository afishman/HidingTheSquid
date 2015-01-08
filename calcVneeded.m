clear all

lambdaC=4;
lambdaP=1+1/3;
% lambdaC=5;
% lambdaP=1.25;

Vlist=linspace(0,4000,1000);

for i=1:length(Vlist)
    V=Vlist(i);
    f(i) = (sigmaElec(lambdaC,V) - sigmaMat(lambdaC))*lambdaC^-1 + sigmaMat(lambdaP)*lambdaP^-1 ;
end
close all
plot(Vlist,f);
grid on