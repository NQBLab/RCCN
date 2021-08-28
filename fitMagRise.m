function [fitresult, gof] = fitMagRise(time, mag_B, lmin, lmax)

[xData, yData] = prepareCurveData( time, mag_B );

ft = fittype(@(tau0,sat_mag,x) sat_mag - (sat_mag*tau0^(1/2)*pi^(1/2)*(erf(x.^(1/2)/(lmax^(1/2)*tau0^(1/2))) - erf(x.^(1/2)/(lmin^(1/2)*tau0^(1/2)))))./(x.^(1/2)*(2/lmax^(1/2) - 2/lmin^(1/2))));
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0,0];
opts.StartPoint = [1,1];
opts.Upper = [Inf,Inf];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );




