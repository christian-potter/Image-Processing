function [] = compare_cmat(cmat1,label1,cmat2,label2,dmatrix,opt)
arguments 
    cmat1 double 
    label1 string
    cmat2(:,:) double 
    label2 string 
    dmatrix (:,:) double % x/y then z 
    opt.plot_hist logical = false 
    opt.dthresh = 0; % defaults to greater than 0 (all distances)
    % negative value will result in < 
    opt.nbins double = 50
    opt.specfig double =[] % specifies figure number for each of plots 
    opt.specsubplot double =[] % specifies subplot number for each of plots 
end

%% MAKE VARIABLES 
u1= triu(cmat1,1); u1(u1==0)=[]; 
u2= triu(cmat2,1); u2(u2==0)=[]; 


udist=triu(dmatrix,1); 

udist(udist==0)=[]; 

if opt.dthresh>=0
    u1 = u1(udist>opt.dthresh); 
    u2 = u2(udist>opt.dthresh); 
    dstring= ['Pairwise Distances Greater Than ', num2str(opt.dthresh),' Microns']; 
elseif opt.dthresh < 0
    u1 = u1(udist<abs(opt.dthresh));
    u2 = u2(udist<abs(opt.dthresh)); 
    dstring= ['Pairwise Distances Less Than ', num2str(abs(opt.dthresh)),' Microns']; 
end

%% SCATTER PLOT 
if isempty(opt.specfig)
    figure('color','w')
else 
    figure(opt.specfig(1))
    subplot(opt.specsubplot(1),opt.specsubplot(2),opt.specsubplot(3))
end

hold on 
scatter(u1,u2)
xlabel([label1,' Correlation'])
ylabel([label2,' Correlation'])
axis([xlim ylim])
plot([-10 10],[-10 10],'LineStyle','--')
utils.sf
title({'Comparison of Correlation Matrices',dstring})
xline(0);yline(0); 

%% HISTOGRAM 

if opt.plot_hist 
    
    if isempty(opt.specfig)
        figure('color','w')
    else
        figure(opt.specfig(2))
        subplot(opt.specsubplot(1),opt.specsubplot(2),opt.specsubplot(3))
    end

    hold on 
    histogram(u1,opt.nbins)
    histogram(u2,opt.nbins)
    legend({label1,label2}); 
    utils.sf
    title({'Histograms of Correlation Matrices',dstring})
    xlabel('Correlation Magnitude')
    ylabel('Frequency')

end
