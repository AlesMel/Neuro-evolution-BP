% l = load("NNMap05TrainedFusionWithFitSeps.mat").nn;
l = load("NNMap05TrainedCameraWithFitSeps.mat").nn; % naciatnie ulozenej matice objektu NN

gens = 1:1:length(l.fitsSep.pop1(:,1));
close all;
%% 
pop = "pop1"; % vyber populacie
fig = figure("Name", "Populacia - fitness")
subplot(5,1, 1)
plot(gens, l.fitsSep.(pop)(:,1), 'LineWidth', 2, 'Color', "#80C3FF")
title("Pose")
grid on
hold on
subplot(5,1, 2)
plot(gens, l.fitsSep.(pop)(:,2), 'LineWidth', 2, 'Color', 'r')
title("Steps")
grid on
subplot(5,1, 3)
plot(gens, l.fitsSep.(pop)(:,3), 'LineWidth', 2,'Color',  'g')
title("Chpts")
grid on
subplot(5,1, 4)
plot(gens, l.fitsSep.(pop)(:,4), 'LineWidth', 2,'Color',  '#EDB120')
title("Finish")
grid on
subplot(5,1, 5)
plot(gens, l.fitsSep.(pop)(:,5), 'LineWidth', 2,'Color', 'magenta')
title("Inside")
grid on
hold off
han=axes(fig,'visible','off'); 
han.XLabel.Visible='on';
han.YLabel.Visible='on';
xlabel(han,'Generácia');
ylabel(han,'Hodnota');
figure("Name", "Populacia č. 1")
subplot(3,1, [1, 2])
plot(gens, l.fitsSep.(pop)(:,6), 'LineWidth', 2, 'Color', "#80C3FF")
xlabel("Generácia");
ylabel("Fitness hodnota")
title("Fitness")
legend('Priebeh fitness', 'orientation', 'horizontal', 'location', 'southoutside')
grid on
hold off
ylim([-4000 15000])
yticks(-3000:4500:15000)
subplot(3,1,3)
plot(gens, l.fitsSep.(pop)(:,7), 'LineWidth', 2, 'Color', '#EDB120')
title("Dosiahnuté checkpointy")
xlabel("Generácia");
ylabel("Checkpoint")
grid on