%% ProjectPair

clear all,close all,clc

ewa  = readtable('EWA.csv')
ewc  = readtable('EWC.csv')

prices= [ewa.AdjClose ,ewc.AdjClose]

logPrices = log(prices);

numAssets = size(prices,2);
numDays = size(prices,1);

cMat = zeros(numAssets,numAssets);
coint = []; 
k = 1;

%ADF ho= non stationarity.
%Rejecting H0 = HA: fail to reject no stationary

adftest(prices(:,1)) % ADF : 1 => HA: stationary  !
adftest(prices(:,2))

for i=1:numAssets % in case we want to do more than 2 assets
    for j=i+1:numAssets
        tmpPrices = [logPrices(:,i) logPrices(:,j)];
        [h,~,~,~,reg] = egcitest(tmpPrices);% Engle-Granger procedure
        cMat(i,j) = reg.coeff(2);
        cMat(j,i) = cMat(i,j);
        coint(k,:) = [i j reg.coeff(1) reg.coeff(2) 0]; % donne les deux assets cointegrés et les betas pour le spread.
        k = k + 1;
    end
end


k = k - 1 % Number of cointegrated pairs

spreads = zeros(numDays,k)
quot = zeros(numDays,k)

for i=1:k % for every cointegrated pair
    tmpPrices = [logPrices(:,coint(i,1)) logPrices(:,coint(i,2))];
    c0 = coint(i,3);
    beta = [1; -coint(i,4)];
    spreads(:,i) = zscore(tmpPrices*beta - c0); % zscore out of step 4
    quot(:,i) = prices(:,coint(i,1))./prices(:,coint(i,2));
end

%% Compute positions 

p = positionPair(spreads);
i = 1;
lQuot = logPrices(:,coint(i,1))./logPrices(:,coint(i,2));
h1 = subplot(3,1,1); plot(1:numDays, logPrices(:,coint(i,1)), 1:numDays, logPrices(:,coint(i,2))); axis tight; grid on; hold on;
h2 = subplot(3,1,2); plot(spreads(:,i)); axis tight; grid on; hold on;
                     plot(2*ones(numDays,1), 'r');
                     plot(-2*ones(numDays,1), 'r');
                     plot(zeros(numDays,1), 'g');
h3 = subplot(3,1,3); stairs(p(:,i), 'linewidth', 1); axis tight; grid on;
linkaxes([h1, h2, h3], 'x');