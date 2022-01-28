% converting image to binary occupancy map
w = warning ('off','all');

[map] = processImg();
map = imresize(map, 2);
mapSize = length(map);
map= binaryOccupancyMap(map)

finish = [90 160; 90 170];

checkPoints = [120 160; 120 170; 
               158 110; 168 110; 
               80 108; 84 104;
               40 120; 50 120]

% initial positions
xCar = 100;
yCar = 200 - 35;
pose = [xCar; yCar; 0]; % origin of a car

% vehicle velocity, this will determine the step calculated with an angle
% of cosinus and sinus

maxRange = 50;
velocity = 1;
angle = pi/4;

% define the vehicle
viz = Visualizer2D;
viz.robotRadius = 1;

viz.showTrajectory = false;
viz.mapName = 'map';
% viz(pose)

release(viz); % Needed to change hasLidar property after visualizing
lidar = LidarSensor;
lidar.scanAngles = linspace(-pi/2,pi/2, 10); % 10 scanned angles
lidar.maxRange = maxRange; % maximum range of a lidar sensor in [meters]
attachLidarSensor(viz,lidar);
tic
ranges = lidar(pose);
toc

viz(pose, ranges)

hold on

% plot(finish(:,1), finish(:,2), 'g', 'lineWidth', 2); % finish line plotting
% 
% % plot checkpoints
i = -1;
while i ~= length(checkPoints)-1
    i = i + 2;
    plot(checkPoints(i:i+1,1), checkPoints(i:i+1,2), 'b', 'LineWidth', 3);
end
% title('Map with vehicle')

%% Neural Evolution
% ------ Architecture of NN ------
popSize = 100;
% neurons = 10; % vstup
gens = 1000;

inputNeurons = 10;              % pocet vstupnych neuronov
hiddenLayer = [20 20];
outputNeurons = 1;              % pocet vystupnych neuronov

M1 = 1;   % maximum def. oboru aktivacnej funkcie hyperbolicky tangens,  M1=1;  M1=3;
M2 = 1;   % M2=1;
M3 = 1;   % maximum jedneho vystupu siete

l1w = inputNeurons * hiddenLayer(1);    % pocet vah medzi input a 2. vrstvou
l2w = hiddenLayer(1) * hiddenLayer(2);  % pocet vah medzi 1. a 2. vrstvou
l3w = hiddenLayer(2) * outputNeurons;   % pocet vah medzi 2. a output vrstvou

l1b = hiddenLayer(1);   % pocet biasov 1. skrytej vrstvy
l2b = hiddenLayer(2);   % pocet biasov 2. skrytej vrstvy
params = [inputNeurons; l1w; l2w; l3w; l1b; l2b];

% ------ Inicialization of NN ------
% definujme velkost prehladavaneho priestoru

space = [-M1*ones(1,l1w) -M2*ones(1,l2w) -M3*ones(1,l3w) -M1*ones(1,l1b) -M2*ones(1,l2b);
    M1*ones(1,l1w) M2*ones(1,l2w) M3*ones(1,l3w) M1*ones(1,l1b) M2*ones(1,l2b)];  % range

space1=space(2,:)/10;  % rozsah lokalnej mutacie 1
space2=space(2,:)/100; % rozsah lokalnej mutacie 2
space3=space(2,:)/1000;


pop = genrpop(popSize, space);

car = pop(1,:);

fit = zeros(popSize, 1);
poses = zeros(popSize, 1000, 3);
fitGen = zeros(gens, 1);

for i = 1:gens

    if mod(i, 1) == 0
        fprintf("------------ Current generation: %d\n ------------", i)
    end
    
    parfor j = 1:popSize
        [fit(j), poses(j,:,:)] = fitnessVehicle(pop(j, :), hiddenLayer, params, map, lidar, pose, maxRange, ranges, i);
    end
    
    % selekcia
    best = selbest(pop, -fit, [25 10]);
    work1 = selbest(pop, -fit, 20);
    work2 = seltourn(pop, -fit, 20);
    work3 = selrand(pop, -fit, 25);

    % krizenie
    work1 = intmedx(work1, 0.25);

    % mutacie
    work2 = mutx(work2, 0.1, space);
    work3 = muta(work3, 0.1, (space/10), space);

    % nova populacia
    pop = [best; work1; work2; work3];
    
    fitGen = min(fit);
    
end

%%
posesToSim = [poses(popSize,:,1)' poses(popSize, :, 2)' poses(popSize, :, 3)'];
posesToSim = posesToSim(~all(posesToSim == 0, 2),:);
for i = 1:length(posesToSim)
    pose = posesToSim(i,:,:)';
    ranges = lidar(pose);
    viz(pose, ranges)
    pause(0.25)
end







