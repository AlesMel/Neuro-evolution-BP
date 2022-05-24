close all
%% 
path = "D:\FEI-STU\BAKALARSKA_PRACA\CIRCUITS\";
img = path+"bigMap.png";
checkpoints = [];
scale = 1;
maxSteps = 1;
finish = [311 311 343 343 311, 100 90 90 100 100] / scale;

map = Map(1);

car = Car(70, 30, pi/4, map, 2);
subplot(2,1,1)
car.drawCar();
subplot(2,1,2)  
show(map.map)
set(gca, 'Ydir', 'reverse')

angle = 0;
x = 0;
dt = 0.1;

%% 

% xs = zeros(100, 2);
% ys = zeros(100, 2);

while x < 100
    clf
    if dt > 2
        angle = -pi/120;
    else
        angle = pi/120;
    end
    car = car.update(angle, 1, 0);

    car.drawCar();
    pause(0.0001)

    x = x + 1;

    dt = dt + 0.1;
end

plot(xs(:), ys(:), 'rX');
xlim([0, 100])
ylim([0, 100])