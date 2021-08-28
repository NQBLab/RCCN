function [mag_relax_b] = getMagRelax(time, Tw, sat_mag, tau0, tau1, lmin, lmax)
%  returns the theoretical function for the relaxation of the magnetization over 
%  time, according to the age of the system
    f = @(x) (((sat_mag*tau1^(1/2)*pi^(1/2)*(erf(x.^(1/2)/(lmax^(1/2)*tau1^(1/2))) - erf(x.^(1/2)/(lmin^(1/2)*tau1^(1/2)))))./(x.^(1/2)*(2/lmax^(1/2) - 2/lmin^(1/2))) - (sat_mag*tau0^(1/2)*tau1^(1/2)*pi^(1/2)*(erf((tau1*Tw + tau0*x).^(1/2)/(lmax^(1/2)*tau0^(1/2)*tau1^(1/2))) - erf((tau1*Tw + tau0*x).^(1/2)/(lmin^(1/2)*tau0^(1/2)*tau1^(1/2)))))./((2/lmax^(1/2) - 2/lmin^(1/2))*(tau1*Tw + tau0*x).^(1/2))));
    mag_relax_b = f(time);
end

