function [cdf] = getCDF(exp_num,init_time,Tw,mag)
% returns the cdf of the time in which the system returned to it's base
% level.
% calculate the pdf:
    pdf = zeros(1,40000);
    for curr_exp = 1:exp_num
        m = mag(curr_exp,:);
        mBase = mean(m(init_time-1000:init_time)); % base level
        mRelaxation = mag(curr_exp,1+init_time+Tw:end); % magnetization after H is turned off
        mRelaxation = mRelaxation-mBase;
        i = find(mRelaxation<0,1); % the first time the magnetization is below the base level
        if length(i)==0
            display(['not crossed: ',num2str(curr_exp)])
        end
        pdf(i) = pdf(i)+1;
    end
 %calculate the cdf:
    pdf = pdf/sum(pdf);
    cdf = cumsum(pdf)/sum(pdf);

end