function data = ssChecker
clc

%A reference object
% load refObj.mat
load refObj

%Loop through and change tHe number of elements that are on
nElemOnList = 1:obj.nElec;

linewidth=3; markerSize=10;

%Cycle through and solve
for i=1:obj.nElec
    %The number of elements that are on
    nElemOn = nElemOnList(i);
    
    %Find the steady state
    [lambdaAct(i), lambdaUni(i)]=findSS(nElemOn, obj);
end

%outpue
data.lambdaPas=lambdaAct;
data.lambdaUni=lambdaUni;

%plot
close all; hold on
x=1:obj.nElec;
save debug
%For bounds on r_on
%Various steady state ss types
noNeigh=(lambdaUni+lambdaUni)./2;
oneNeigh=(lambdaAct+lambdaUni)./2;
twoNeigh=(lambdaAct+lambdaAct)./2;

%Do plotting
%r_on,1
plot([0,x(end)],[oneNeigh(end-1), oneNeigh(end-1)],'g','linewidth',linewidth)

%r_on,2
plot([0,x(end)],[oneNeigh(1), oneNeigh(1)],'b','linewidth',linewidth)

%r_off,1 
plot([0,x(end)],[noNeigh(1), noNeigh(1)],'k','linewidth',linewidth)

%r_off,2
plot([0,x(end)],[twoNeigh(end), twoNeigh(end)],'r','linewidth',linewidth)

% plot([x(1),x(end)],[rOff1(end), rOff1(end)],'r','linewidth',linewidth)
n=[1:obj.nElec-1];plot([0,x(n)],[obj.preStretch,noNeigh(n)],'kx','MarkerSize',markerSize)
n=[1:obj.nElec];plot(x(n),oneNeigh(n),'bo','MarkerSize',markerSize)
n=[2:obj.nElec];plot(x(n),twoNeigh(n),'r+','MarkerSize',markerSize)

% plot(x,rOn,'b')
% plot(x,rOff1,'r')
% plot(x,rOff2,'k')



legend('r_{on,1}','r_{on,2}','r_{off,1}','r_{off,2}',...
    'No Neghbours','One Neghbours','Two Neghbours')

xlabel('Number of Activated Cells')
ylabel('Steady State Source-Strain')
xlim([0,obj.nElec])
xTick=get(gca, 'XTick');

xlim([0,obj.nElec+10])
set(gca, 'XTick', xTick)


function [lambdaA_out, lambdaB_out]=findSS(a, obj)
%%%%Main Routiune
%THe number of elements that are on
b = obj.nElem - a;

%Important info
theLength = obj.theLength;
L = obj.L;

%Lamnda_U as a function of lambda_1
lambdaA = @(lambdaB) (theLength./L - b.*lambdaB)./a;

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
f = @(lambdaB)...
    (sigmaElec(lambdaA(lambdaB), V) - sigmaMat(lambdaA(lambdaB), lambdaA(lambdaB)) ...
    ).* lambdaA(lambdaB).^-1 ...
    + ...
    sigmaMat(lambdaB, lambdaB) .* lambdaB.^-1;
    



%%%%Perform calculations
% %The List
% x = linspace(1,6,1000);
% 
% y = f(x);
% save debug
% % % Plot
% % close all
% % plot(x,y)
% % grid on
% % 
% % 
lambdaB_out=fzero(f, 2);

lambdaA_out=lambdaA(lambdaB_out);
