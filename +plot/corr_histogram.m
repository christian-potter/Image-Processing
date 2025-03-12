function [] = corr_histogram(mat,d,t)
% Function that plots the histogram of all the pairwise correlations of a
% matrix 

% INPUTS: 
% mat : matrix of values to plot 
% d : structure with activity information 
% t : title 

%% VARIABLES 
cm= triu(mat,1); cm(cm==0)=[];
mean_cm= mean(cm,'omitnan'); std_cm = std(cm,'omitnan'); 

%% MAKE FIGURE 
figure 
histogram(cm)
xlabel('Pairwise Correlation')
ylabel('Freqency')
title({t,['Dataset #',num2str(d.tag)]})

%% EDIT FIGURE 
utils.set_figure(15,'no')
xline(mean_cm,'Color','r','LineWidth',2)
xline([mean_cm+std_cm, mean_cm-std_cm],'Color','r','LineWidth',2,'LineStyle','--')
text(.66,.6,['Mean: ',num2str(mean_cm)],'Units','Normalized','FontSize',15,'Color','r')
text(.66,.5,['St Dev: ',num2str(std_cm)],'Units','Normalized','FontSize',15,'Color','r')


end



