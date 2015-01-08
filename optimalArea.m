clear all

list = linspace(1,2,100);

for i=1:length(list)


lambdaC=3;
lambdaP=list(i);


lambdaPre = sqrt(lambdaC*lambdaP);
res(i) = lambdaPre;

a = ((lambdaPre-lambdaC)*(lambdaP-lambdaPre)) /...
    ((lambdaC-lambdaP)*lambdaPre)

important(i) = (lambdaPre-lambdaC)/(lambdaP-lambdaPre);

end
close all
plot(list, important)
