% ----------- %
close all
clc
clear
% ----------- %
%%
figure('Position', [100, 100, 800, 500]);

variant = 3;
scale = 1;
sensorMode = 2;
%% 

path = "CIRCUITS\";
switch variant
    case 1
        img = path+"O.png";
        xCar = 55 / scale;
        yCar = 70 / scale;
        maxSteps = 250 * scale;
        anlge = 0;
        finish = [47 49 49 47 47, 66 66 80 80 66] / scale;
        checkpoints = [[61 63 63 61 61] [66 66 80 80 66];
            [75 77 77 75 75] [66 66 80 80 66];
            [82 82 94 94 82] [64 62 62 64 64];
            [82 82 94 94 82] [50 52 52 50 50];
            [82 82 94 94 82] [36 38 38 36 36];
            [75 77 77 75 75] [18 18 32 32 18];
            [61 63 63 61 61] [18 18 32 32 18];
            [47 49 49 47 47] [18 18 32 32 18];
            [33 35 35 33 33] [18 18 32 32 18];
            [20 22 22 20 20] [18 18 34 34 18];
            [8 8 20 20 8]    [38 36 36 38 38];
            [8 8 20 20 8]    [52 50 50 52 52];
            [8 8 20 20 8]    [64 62 62 64 64];
            [22 24 24 22 22] [66 66 80 80 66];
            [34 36 36 34 34] [66 66 80 80 66]] / scale;
    case 2
        %ZigZagRoad
        img = path+"ZigZagRoad.png";
        xCar = 12 * scale;
        yCar = 5 * scale;
        angle = 0;
        maxSteps = round(10000 * scale);
        finish = [148   156   156   148   148,   145   145   147   147   145] * scale;
        width = 2;
        checkpoints =   [30	31	31	30	30	1	1	9	9	1;
                        42	42	50	50	42	21	22	22	21	21;
                        60	61	61	60	60	30	30	38	38	30;
                        85	86	86	85	85	30	30	38	38	30;
                        86	85	85	86	86	51	51	59	59	51;
                        61	61	69	69	61	63.5	64.5	64.5	63.5	63.5;
                        53.5	52.5	52.5	53.5	53.5	82	82	90	90	82;
                        42	42	50	50	42	110	111	111	110	110;
                        67.5	68.5	68.5	67.5	67.5	131	131	139	139	131;
                        95	96	96	95	95	113	113	121	121	113;
                        140	141	141	140	140	113	113	121	121	113]  * scale;
    case 3
        img = path+"bigMap.png";
        xCar = 70 * scale;
        yCar = 30 * scale;
        angle = 0;
        maxSteps = round(700 * scale);
        finish = [311 311 343 343 311, 100 90 90 100 100] / scale;
        checkpoints = [120 130 130 120 120, 46 46 14 14 46;
                       180 190 190 180 180, 46 46 14 14 46;
                       190 180 180 190 190, 75 75 107 107 75;
                       130 120 120 130 130, 75 75 107 107 75;
                       78 78 110 110 78, 157 167 167 157 157;
                       78 78 110 110 78, 217 227 227 217 217;
                       120 130 130 120 120, 255 255 287 287 255;
                       180 190 190 180 180, 226 226 194 194 226;
                       240 250 250 240 240, 226 226 194 194 226;
                       250 240 240 250 250, 257 257 289 289 257;
                       240 250 250 240 240, 318 318 350 350 318;
                       300 310 310 300 300, 318 318 350 350 318;
                       311 311 343 343 311, 278 268 268 278 278;
                       311 311 343 343 311, 218 208 208 218 218;
                       311 311 343 343 311, 158 148 148 158 158;];
    case 4
        img = path+"bigMap3.png";
        xCar = 190 * scale;
        yCar = 55 * scale;
        angle = pi/2;
        maxSteps = round(700 * scale);
        finish = [330 340 340 330 330, 340 340 372 372 340] / scale;
        checkpoints = [220 230 230 220 220,  73 73 41 41 73;
                       237 237 269 269 237, 120 130 130 120 120;
                       298 298 330 330 298, 190 200 200 190 190;
                       248 238 238 248 248, 234 234 202 202 234];
end

map = Map(img, scale, checkpoints, finish, maxSteps);
car = Car(xCar, yCar, angle, map, sensorMode);

nn = NN([100 100 45], [10 6 6 2], 2);

car.drawCar();
%% 
fit1 = nn.fits.fit1;
fit2 = nn.fits.fit2;
fit3 = nn.fits.fit3;

fitPrev1 = fit1;
fitPrev2 = fit2;
fitPrev3 = fit3;
checkpointsReached1 = zeros(nn.populationSizes(1), 1);
checkpointsReached2 = zeros(nn.populationSizes(2), 1);
checkpointsReached3 = zeros(nn.populationSizes(3), 1);

pop1 = nn.populations.pop1;
pop2 = nn.populations.pop2;
pop3 = nn.populations.pop3;

space = nn.space;
space1 = space/5;
space2 = space/50;
space3 = space/500;

gens = 999;

fitS1 = cell(gens, 5);
fitS2 = cell(gens, 5);
fitS3 = cell(gens, 5);

fitTrend1 = zeros(gens, 1);
fitTrend2 = zeros(gens, 1);
fitTrend3 = zeros(gens, 1);

for i = 1:gens
    dFit1 = fit1 - fitPrev1;
    dFit2 = fit2 - fitPrev2;
    dFit3 = fit3 - fitPrev3;

    if mod(i, 1) == 0
        fprintf("------------ Current generation: %d  ------------\n", i)
    end

    parfor j = 1:nn.populationSizes(1,1)
        [fit1(j), checkpointsReached1(j), ~] = fitness(nn, map, car, 1, j);
    end
    
    parfor j = 1:nn.populationSizes(1,2)
        [fit2(j), checkpointsReached2(j), ~] = fitness(nn, map, car, 2, j);
    end

    parfor j = 1:nn.populationSizes(1,3)
        [fit3(j), checkpointsReached3(j), ~] = fitness(nn, map, car, 3, j);
    end

    nn.fits.fit1 = fit1;

    best_1 = selbest(pop1, fit1, [1, 1]);
    old_1 = selrand(pop1, fit1, 10);
    work1a_1 = seltourn(pop1, fit1, 10);
    work1b_1 = seltourn(pop1, fit1, 10);
    work1_1 = [work1a_1; work1b_1; best_1];

    work2a_1 = seltourn(pop1, fit1, 10);
    work2b_1 = seltourn(pop1, dFit1, 10);
    work2_1 = [work2a_1; work2b_1; best_1];

    work3a_1 = selsus(pop1, fit1, 10);
    work3b_1 = selsus(pop1, dFit1, 10);
    work3_1 = [work3a_1; work3b_1; best_1];

    work4a_1 = selsus(pop1, fit1, 10);
    work4b_1 = selsus(pop1, dFit1, 10);
    work4_1 = [work4a_1; work4b_1; best_1];
    pop1 = [best_1; work1_1; work2_1; work3_1; work4_1; old_1];

     % GA - 2. Island - pop will be reset
    best_2 = selbest(pop2, fit2, [1, 1]);
    old_2 = selrand(pop2, fit2, 10);
    work1a_2 = seltourn(pop2, fit2, 10);
    work1b_2 = seltourn(pop2, fit2, 10);
    work1_2 = [work1a_2; work1b_2; best_2];

    work2a_2 = seltourn(pop1, fit1, 10);
    work2b_2 = seltourn(pop1, dFit2, 10);
    work2_2 = [work2a_2; work2b_2; best_2];

    work3a_2 = selsus(pop1, fit1, 10);
    work3b_2 = selsus(pop1, dFit2, 10);
    work3_2 = [work3a_2; work3b_2; best_2];

    work4a_2 = selsus(pop1, fit1, 10);
    work4b_2 = selsus(pop1, dFit2, 10);
    work4_2 = [work4a_2; work4b_2; best_2];

    work1_2 = intmedx(work1_2, 0.4);
    work2_2 = mutx(work2_2, 0.1, space);
    work3_2 = muta(work3_2, 0.1, space2, space);
    work4_2 = muta(work4_2, 0.1, space3, space);
    pop2 = [best_2; work1_2; work2_2; work3_2; work4_2; old_2];

    % GA - 3. Island - the best ones
    best_3 = selbest(pop3, fit3, [1,1,1,1,1]);
    work_3 = selbest(pop3, fit3, [1,1,1,1,1,1,1,1,1,1]);

    work1_3 = muta1(work_3, space2, space);
    work2_3 = muta1(work_3, space2, space);
    work3_3 = muta1(work_3, space1, space);
    work4_3 = muta1(work_3, space1, space);
    pop3=[best_3; work1_3; work2_3; work3_3; work4_3];

    nn = nn.updatePop(1, pop1);
    nn = nn.updatePop(2, pop2);
    nn = nn.updatePop(3, pop3);

    % migracia z ostrova 1 do ostrova 2, z ostrova 3 do 1, zahrievanie ostrova 1,
    if mod(i, 200)==0
        pop3(10, :) = pop1(1,:);  % migracia z Pop_1 do Pop_3
        pop3(11, :) = pop2(1,:);  % migracia z Pop_2 do Pop_3
        pop2(10, :) = pop1(1,:);
        pop1(10, :) = pop2(1,:);

        popa_1 = pop1(1:50, :);
        popb_1 = pop1(51:100, :);
        popa_1 = warmpopm(popa_1, 0.3); % zahreje 1. polovicu populacie 1
        popb_1 = warmpopm(popb_1, 0.6); % zahreje 2. polovicu populacie 1
        pop1 = [popa_1; popb_1];

        [nn, pop2] = nn.resetPop(2); % resetuje pop
    end

    maxCheckpointsReached1 = max(checkpointsReached1);
    maxCheckpointsReached2 = max(checkpointsReached2);
    maxCheckpointsReached3 = max(checkpointsReached3);
    
    nn = nn.fitTrendInsert(1, i, min(fit1));
    nn = nn.fitTrendInsert(2, i, min(fit2));
    nn = nn.fitTrendInsert(3, i, min(fit3));
%     fitTrend1(i) = min(fit1);
%     fitTrend2(i) = min(fit2);
%     fitTrend3(i) = min(fit3);

    fprintf("------------ Checkpoints reached:\n")
    cprintf('red'," 1. island: %d  \n", maxCheckpointsReached1)
    cprintf('red'," 2. island: %d  \n", maxCheckpointsReached2)
    cprintf('red'," 3. island: %d  \n", maxCheckpointsReached3)
end


%%         
figure('Position', [100, 100, 800, 500]);
img = path+"bigMap3.png";
finish = [330 340 340 330 330, 340 340 372 372 340] / scale;
checkpoints = [220 230 230 220 220,  73 73 41 41 73;
               237 237 269 269 237, 120 130 130 120 120;
               298 298 330 330 298, 190 200 200 190 190;
               248 238 238 248 248, 234 234 202 202 234];
xCar = 190 * scale;
yCar = 45 * scale;
angle = pi/2;
testMap = Map(img, scale, checkpoints, finish, maxSteps);
step = 0;

popIndex = 2;
geneIndex = 1;
% load("NNCameraMap03Trained06Camera.mat");
[nn, weights] = nn.convertWeights(popIndex, geneIndex);
car = Car(xCar, yCar, angle, testMap, sensorMode);
car.drawCar()
speeds = zeros(maxSteps, 1);

while step < maxSteps && ~testMap.checkFinish(car.carPosition)
    [sensorReadings, cameraReadings] = car.getSensorReadings();
    switch car.sensorMode
        case 1
            [out] = nn.evaluateOutput(sensorReadings, pi/4, weights, popIndex, geneIndex); % get output angle
        case 2
            [out] = nn.evaluateOutput(cameraReadings, pi/4, weights, popIndex, geneIndex); % get output angle
        case 3
            [out] = nn.evaluateOutput([sensorReadings, cameraReadings'], pi/4, weights, popIndex, geneIndex); % get output angle
    end
    car = car.update(out(1), out(2));
    car.drawCar();
    pause(0.0001);
    step = step + 1;
    xs(step) = car.carPosition(1);
    ys(step) = car.carPosition(1,2);
    speeds(step) = car.speed;
end

show(testMap.map)
hold on
plot(xs(:), ys(:), 'rX');
set(gca, 'Ydir', 'reverse')
%% 
figure
generations = 1:1:gens;
plot(generations, nn.fitTrend.pop3)