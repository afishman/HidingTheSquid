% function data = ssChecker
clc

%A reference object
% load refObj.mat
load refObj

%Loop through and change tHe number of elements that are on
nElemOnList = 1:obj.nElec;

linewidth=1.5; markerSize=10;

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
% plot([x(1),x(end)],[rOff1(end), rOff1(end)],'r','linewidth',linewidth)
n=[1:obj.nElec-1];plot([0,x(n)],[obj.preStretch,noNeigh(n)],'kx','MarkerSize',markerSize)
n=[1:obj.nElec];plot(x(n),oneNeigh(n),'bo','MarkerSize',markerSize)
n=[2:obj.nElec];plot(x(n),twoNeigh(n),'r+','MarkerSize',markerSize)

%r_on,1
color_rOn1 = 'k';
plot([0,x(end)],[oneNeigh(end-1), oneNeigh(end-1)],color_rOn1,'linewidth',linewidth)
% plot([0,x(end)],[oneNeigh(end-1), oneNeigh(end-1)],'g','linewidth',linewidth)

%r_on,2
color_rOn2 = 'k';
plot([0,x(end)],[oneNeigh(1), oneNeigh(1)],color_rOn2,'linewidth',linewidth)

%r_off,1
color_rOff1 = 'k';
plot([0,x(end)],[noNeigh(1), noNeigh(1)],color_rOff1,'linewidth',linewidth)

%r_off,2
color_rOff2 = 'k';
plot([0,x(end)],[twoNeigh(end), twoNeigh(end)],color_rOff2,'linewidth',linewidth)

%%%The limits
xlimits = [0,obj.nElec];
ylimits = get(gca, 'YLim');



%%%Threshold ranges
shift = 0.05;
width = 1.05;

%For the bast of the brackets
stub = shift*obj.nElec+[obj.nElec, width*obj.nElec];
stubMid = [mean(stub), mean(stub)];

%Two neighbours
plot(stub, [twoNeigh(end), twoNeigh(end)],'k')
plot(stubMid, [twoNeigh(end), ylimits(2)],'k')
text(stub(end), mean([twoNeigh(end), ylimits(2)]), 'Deactivate');

%One neighbours
plot(stub, [oneNeigh(end-1), oneNeigh(end-1)],'k')
plot(stub, [oneNeigh(1), oneNeigh(1)],'k')
plot(stubMid, [oneNeigh(1), oneNeigh(end-1)],'k')
text(stub(end), mean([oneNeigh(1), oneNeigh(end-1)]), 'Activate');

%No Neighbours neighbours
plot(stub, [noNeigh(1), noNeigh(1)],'k')
plot(stubMid, [noNeigh(1), ylimits(1)],'k')
text(stub(end), mean([noNeigh(1), ylimits(1)]), 'Deactivate');

% plot(x,rOn,'b')
% plot(x,rOff1,'r')
% plot(x,rOff2,'k')
% text(0,3,'Blah')


% legend('r_{on,1}','r_{on,2}','r_{off,1}','r_{off,2}',...
%     'No Neghbours','One Neghbours','Two Neghbours')
h=legend('No Neghbours','One Neghbours','Two Neghbours','Rule Base Limit');
set(h, 'Location','EastOutside')

xlabel('Number of Activated Cells')
ylabel('Steady State Source')
xlim(xlimits)
xTick=get(gca, 'XTick');

xlim([0,obj.nElec+9])
set(gca, 'XTick', xTick)

%Clean up
xlimits = get(gca, 'XLim');
plot([obj.nElec+0.1, xlimits(2)+1],[ylimits(1),ylimits(1)],'w')







% %%%%%Find steady state
% function [lambdaAct, lambdaUni]=findSS(nElemOn, obj)
% % %Write lambda1 here once you find it and rerun
% % lambda1 = 5.02;
% 
% 
% 
% %%%%Main Routiune
% %THe number of elements that are on
% nElemOff = obj.nElem - nElemOn;
% 
% %Important info
% theLength = obj.theLength;
% L = obj.L;
% 
% %The sum of the stretch ratios
% sumOfStretch = obj.preStretch*obj.nElem;
% 
% %Lamnda_U as a function of lambda_1
% lambdaU = @(lambda) (sumOfStretch - nElemOn.*lambda)./nElemOff;
% 
% %%%%Sigma Mat function
% muA=obj.muA; muB=obj.muB; Ja=obj.Ja; Jb=obj.Jb;
% sigmaMat = @(lambda, xi) ...
%     (muA*(lambda.^2 - lambda.^-4))./...
%     (1 - (2*lambda.^2 + lambda.^-4 - 3)./Ja)...
%     + ...
%     (muB*(lambda.^2.*xi.^-2 - lambda.^-4.*xi.^4))./...
%     (1 - (2*lambda.^2.*xi.^-2 + lambda.^-4.*xi.^4)./Jb);
% 
% %%%%Sigma Elec Function
% eRel = obj.eRel; T = obj.T; V = obj.Vs;
% %Electrical Stress
% sigmaElec = @(lambda,V) eRel * V.^2 * T^-2 .* lambda.^4;
% 
% %%%%Function to solve for roots for
% f = @(lambda)...
%     (sigmaElec(lambda,V) - sigmaMat(lambda,lambda)).*lambda.^-1 +...
%     sigmaMat(lambdaU(lambda), lambdaU(lambda)).*lambdaU(lambda).^-1;
% 
% 
% 
% 
% %%%%Perform calculations
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
% lambdaAct=fzero(f, 5.1);
% 
% lambdaUni=lambdaU(lambdaAct);