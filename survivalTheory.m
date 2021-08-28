function survival_theory = survivalTheory(mean_mag,std_mag,t_plus)
   % set time
   relaxation_time = length(mean_mag);
   t=0:relaxation_time-1;
   % calculate formula's parts
   f = erfc(mean_mag./(sqrt(2)*std_mag));
   g = 1/t_plus * exp(-t/t_plus);
   I = conv(f,g);
   % normalize since this is dicrete convolution
   normalization = exp(1/t_plus)/(t_plus*(exp(1/t_plus)-1));
   I=I./normalization;
   % take only relevant part of convolution
   I = I(t+1);
   % regularize
   regularization_time = 5;
   beta = 2./f-1;
   beta = [beta(1+regularization_time:end),beta(end)*ones(1,regularization_time)];
   
   % calculate formula
   survival_theory = 1 - 1/2 * f - 1/2 * beta .* I;
   
end

