function [fitresult, gof] = fitMagRelaxB15(time, mag_B, Tw, sat_mag, tau0, lmin, lmax)
%  fits the theoretical function for the relaxation of the magnetization over 
%  time to the data, according to the waiting time
%
%  Input:
%      X Input : time
%      Y Output: mag_A_normed (the relaxation starts from 100%)
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.



[xData, yData] = prepareCurveData( time, mag_B );

% Set up fittype and options.
f = @(tau1,x) ((sat_mag*tau1^(1/2)*pi^(1/2)*(erf(x.^(1/2)/(lmax^(1/2)*tau1^(1/2))) - erf(x.^(1/2)/(lmin^(1/2)*tau1^(1/2)))))./(x.^(1/2)*(2/lmax^(1/2) - 2/lmin^(1/2))) - (sat_mag*tau0^(1/2)*tau1^(1/2)*pi^(1/2)*(erf((tau1*Tw + tau0*x).^(1/2)/(lmax^(1/2)*tau0^(1/2)*tau1^(1/2))) - erf((tau1*Tw + tau0*x).^(1/2)/(lmin^(1/2)*tau0^(1/2)*tau1^(1/2)))))./((2/lmax^(1/2) - 2/lmin^(1/2))*(tau1*Tw + tau0*x).^(1/2)));
ft = fittype(@(tau1,x) f(tau1,x));
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0];
opts.StartPoint = [1];
opts.Upper = [Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );






