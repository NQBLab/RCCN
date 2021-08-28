function [] = ShowSimulationData()
% parameters
   
    % action_id:
    % plot_survival - plot the survival curves
    % plot_survival_theory - plot theoretical predicition for the survival
    % plot_survival_and_theory - plot both numeric and theoretical curves
    % plot_mean_magnetizaion - plot mean of magnetization during relaxation
    % plot_magnetization_theory - plot the prediction for the relaxation of magnetization
    % plot_mean_magnetization_and_theory - plot both numeric and theoretical curves
    % find_tau0_and_sat_mat - fit to find tau0 and sat_mag
    action_id = 'plot_survival_and_theory';
    % path to data
    data_folder = 'NumericData/T';
    % if needed, best to erase Tws from the script and not to erase them
    % from the figure in order for the colors to be nice
    Tws = [20,40,160,640,900,1280,2100,2500,3000];
    % experiment parameters
    init_time = 2000; % amount of iterations in the beginning where H=0
    lmin=1; % smallest loop
    lmax=2500; % biggest loop
    relaxation_time = 4000; % time from the cesation of H to the end of the simulation
    % results of fit to mean field
    mean_std = 0.048;
    tau0 = 1;
    sat_mag = 0.4469;
    tau1 = 1.9;
    tauPlus = @(Tw) 80*(Tw/3000)^(1/4);
    % scale and limits
    x_scale = 'log';
    y_scale = 'log';
    % display parameters
    line_width = 2;
    marker_size = 12;
    line_style = '.-';
    font_size = 18;
    

% Open figure
figure1 = figure('WindowState','maximized');
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% set colors according to number of Tws
color_set = viridis(length(Tws)); % plasma also looks nice, parula also but less
set(axes1, 'ColorOrder', color_set);

% draw each Tw
for i=1:length(Tws)
    Tw=Tws(i);
    display(strcat('   --- Tw = ',num2str(Tw),' ---   '));
    load(strcat(data_folder,num2str(Tw)),'mag');
    exp_num = size(mag,1);

    if strcmp(action_id,'plot_survival') || strcmp(action_id,'plot_survival_and_theory')
        cdf = getCDF(exp_num,init_time,Tw,mag);
        survival = 1-cdf;
        t = 1:relaxation_time;
        survival = survival(t);
        plot(t,survival,line_style,'DisplayName',num2str(Tw),'LineWidth',line_width,'MarkerSize',marker_size);
    end
    if strcmp(action_id,'plot_survival_theory') || strcmp(action_id,'plot_survival_and_theory')
        mag_down_theory = getMagRelax(0.01:relaxation_time, Tw, sat_mag, tau0, tau1, lmin, lmax);
        mag_std = mean_std*ones(size(mag_down_theory));
        survival_theory = survivalTheory(mag_down_theory,mag_std,tauPlus(Tw));
        a=plot(survival_theory,'k','DisplayName',num2str(Tw),'LineWidth',line_width,'MarkerSize',marker_size);
        a.Annotation.LegendInformation.IconDisplayStyle = 'Off';
    else
        mag_mean = mean(mag);
        mag_std = std(mag);
        if strcmp(action_id,'find_tau0_and_sat_mat')
            % fit to find tau0 and sat_mag
            mag_up = mag_mean(1+init_time:init_time+Tw);
            [fitresult, ~] = fitMagRise(0.01:Tw,mag_up,lmin,lmax);
            display(['tau0 =',num2str(fitresult.tau0)])
            display(['sat_mag =',num2str(fitresult.sat_mag)])
            plot(fitresult,0.01:Tw,mag_up)
        end
        if strcmp(action_id,'plot_mean_magnetizaion') || strcmp(action_id,'plot_mean_magnetization_and_theory')
            % plot mean of magnetization during relaxation
            mag_down = mag_mean(1+init_time+Tw:end);
            plot(0.01:relaxation_time,mag_down,line_style,'DisplayName',num2str(Tw),'LineWidth',line_width,'MarkerSize',marker_size)
        end
        if strcmp(action_id,'plot_magnetization_theory') || strcmp(action_id,'plot_mean_magnetization_and_theory')
            % plot the prediction for the relaxation of magnetization
            mag_down_theory = getMagRelax(0.01:relaxation_time, Tw, sat_mag, tau0, tau1, lmin, lmax);
            a = plot(0.01:relaxation_time,mag_down_theory,'k--','DisplayName',num2str(Tw),'LineWidth',line_width);
            a.Annotation.LegendInformation.IconDisplayStyle = 'Off';
        end
    end
end
set(axes1,'FontSize',font_size,'XMinorTick','on','XScale',x_scale,'YMinorTick','on','YScale',...
    y_scale);


end