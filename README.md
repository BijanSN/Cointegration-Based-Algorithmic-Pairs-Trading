# Cointegration-Based-Algorithmic-Pairs-Trading
Financial econometrics small project 

# Applied Pair trading in a stochastic volatility framework
## Introduction
The goal of this project is to apply a particular statistical arbitrage strategy using the property of cointegration between assets in a stochastic volatility framework: pair trading.
Pair trading is a quantitative market neutral investment strategy where a pair of assets is formed in order to benefit from the spread between the couple. In our case, we’ll follow a specific decision criterion defined by a Z-score, which will inform when to buy one asset while selling the other.
One could argue that in specific economies, there could be couple of assets which have roughly the same risks and therefore the same expected returns since they are associated with similar risk factors. In the long run, we could think of a mean-reverting process such that the two (or more) assets will eventually come back to their original mean, meaning that, in the long run, they behave the same way.
For illustration, the crude oil market is dominated by two main grades which serves as a benchmark for oil purchases; the WTI known as Texas Light Sweet and the Brent, which is extracted in the North Sea. They are both affected by the (roughly) the same macro economical/industrial/financial shocks, but as they are not entirely similar, their associated risks -and therefore their prices- differs. If we support the hypothesis of long term relationship between these two assets, we could arbitrage during the short term whenever we see an abnormal low price of one of the crude oil by buying it and selling the overpriced one.
## Theoretical background/ methodology
The stochastic volatility model will be used as a background framework. We can model a continuous time process in order to model our assets’ price evolution:
Unlike (G)ARCH models where the variance is constant, we introduce a variance which follows a random process! dWt is a standard Brownian motion, also known as Wiener process. This stochastic integral can be solved using Ito’s lemma:
### Trend stationarity
As we’ve just seen, there is two main components in the price of the asset; a drift mean, which is the deterministic part and the volatility, the stochastic one.
In order to benefit from the spread of the two asset prices, we need to make sure that there is a persistent trend which converges to the mean of the series. In other word, that the two series are stationary.
We’re testing the stationarity of the two series using the Augmented Dickey-Fuller (ADF).
H0: non-stationarity HA: fail to reject non-stationarity

### Cointegration
As we said before, if the implied relationship between the two assets holds true in the long run, it means that we could exploit the short-term spread. Cointegration is a way of describing such structure of relationship (mean reversion).
Be Xt & Yt non-stationary processes such as the logarithm of asset prices. If the residuals of the regression of Yt and Xt are stationary, Yt is said to be cointegrated with Xt.
Log(Yt)= α+ βLog(Xt) + ϵ
Using Engle-Granger procedure, we test the stationarities of such residuals.
### Trading rule
After successful completion of the above steps, the couple of assets is eligible to do our pair trading strategy. They behave the same way in the long term and do not diverge from their mean trend.
Using the regression of the Engle-Granger procedure, we can derive the spread of the two assets:
Log(Yt)- (α+ βLog(Xt))
We’ll then define a threshold (set at 2 times the Standard deviation of the spread) at which we’ll buy one of the asset while selling the other until it returns to their equilibrium ratio.
### Summary of the methodology:
1. Check the stationarity (at least integrated of order 1) with ADF
2. Perform the Engle-Granger procedure (cointegration test)
3. OLS regression to get the coefficients (betas)
4. Compute the spread = AssetA – (alpha+ beta* AssetB)

Examples using Matlab R2018a –Commentary of ProjectPair.m
For our project, we used two indexes; the EWA1 & the EWC2. Those two indexes track respectively the Australian and the Canadian market. The data, downloaded through Yahoo finance, contains their 371 last daily returns from the 1st of July 2017.
After initializing our variables, we compute the returns and log prices of both indexes, as follows:
```Matlab

%% project FE: EWA/EWC
clear all,close all,clc
ewa = readtable('EWA.csv')
ewc = readtable('EWC.csv')
prices= [ewa.AdjClose ,ewc.AdjClose]
logPrices = log(prices);
rets = logPrices(2:end,:)./logPrices(1:end-1,:) - 1;
numAssets = size(prices,2);
numDays = size(prices,1);
cMat = zeros(numAssets,numAssets);
coint = [];
k = 1;

We apply step 1 : the stationary test ( ADF)
adftest(prices(:,1)) % ADF : 1 => HA: stationary !
adftest(prices(:,2))
Then, step 2 : we compute cointegration test on every couple of assets. In our case,only once because we only provide 2 assets, but the code is scalable to multiple assets.
for i=1:numAssets % % in case we want to do more than 2 assets
for j=i+1:numAssets
tmpPrices = [logPrices(:,i) logPrices(:,j)];
[h,~,~,~,reg] = egcitest(tmpPrices);% Engle-Granger procedure
cMat(i,j) = reg.coeff(2);
cMat(j,i) = cMat(i,j);
coint(k,:) = [i j reg.coeff(1) reg.coeff(2) 0]; % give the 2 cointegrated assets & their respective betas for the spread computation
k = k + 1;
end
end
k = k - 1 % Number of cointegrated pairs
spreads = zeros(numDays,k)
for i=1:k % for every cointegrated pair
tmpPrices = [logPrices(:,coint(i,1)) logPrices(:,coint(i,2))];
c0 = coint(i,3);
beta = [1; -coint(i,4)];
spreads(:,i) = zscore(tmpPrices*beta - c0); % zscore out of step 4
quot(:,i) = prices(:,coint(i,1))./prices(:,coint(i,2));
end

```

We finish by plotting the graphical summary of our strategy:
The first window represents the log price of both assets.
The second is the spread of the two assets. The red lines are the threshold at which the pair trading will be executed.
Lastly, the last one computes the underlying position of the strategy.



Conclusion:
Despite poor trading rules, the lack of profits & losses function, we managed to define a trading strategy consistent with the theory. Previous attempts didn’t work out, such as the cointegration between Coca& Pepsi. This highlights a flaw in our sample selection: the replication of this study is very low, because we specifically looked for a couple of existing cointegrated assets. The next step would be to implement a way of determining the ideal timeframe for which the algorithm will maximize the returns/robustness of this strategy. We can try to optimize our trading rule by finding for which standard deviation the rule grants the highest robust significant results on different assets.
