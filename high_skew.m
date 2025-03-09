%%

figure
plot(mean(F,1))
hold on 
xline(stim.tlist(:,1))
xticks([0;stim.tlist(:,1)])
xticklabels(stim.strlist(:,1))
title('Dataset #6')

utils.sf

ylabel('Mean F value')
xlabel('Experiment Epoch')
%%

for i = 1:length(stat)
    skews(i) = stat{i}.skew; 
end

[~,skewidx]=sort(skews); 
F=F(skewidx,:); 
%%
figure

for i = 1:100
    plot(F(i,:))
    xline(stim.tlist(:,1))
    xticks([0;stim.tlist(:,1)])
    xticklabels(stim.strlist(:,1))
    title('Dataset #6')
    pause
end