function stress = sigmaElec(lambda,V)
eRel = 4.5 * 8.854187817 * 10^-12;
T=5e-4;


           
            %Electrical Stress
            stress = eRel * V.^2 * T^-2 .* lambda.^4;
