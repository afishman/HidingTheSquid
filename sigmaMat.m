function stress=sigmaMat(lambda)

muA = 25000;
muB=70000;
Ja=90;
Jb=30;

xi=lambda;


%Network A
netAnum = muA*(lambda.^2 - lambda.^-4);
netAden = 1 - (2*lambda.^2 + lambda.^-4 - 3)./Ja;
netA = netAnum./netAden;

%Network B
netBnum = muB*(lambda.^2.*xi.^-2 - lambda.^-4.*xi.^4);
netBden = 1 - (2*lambda.^2.*xi.^-2 + lambda.^-4.*xi.^4)./Jb;
netB = netBnum./netBden;

%The total stress
stress = netA + netB;