function [fit, checkpointsReached, fitSep] = fitness(nn, map, car, popIndex, geneIndex)

    fitFinish = 0;
    fitChpt = 0;
    fitInside = 0;
    fitPose = 0;
    fit = 0;

    pose = [car.carPosition car.headingAngle];
    step = 0;
    checkpointsReached = 0;

    [nn, weights] = nn.convertWeights(popIndex, geneIndex);

    while step < map.maxSteps
        step = step + 1; % priratavanie kroku

        if map.checkFinish(pose) &&  (map.checkpointCount + 1) == checkpointsReached
%             fitFinish = -1e6;
            fitFinish = -2e3; % ak presiel automobil checkpoint, dostane odmenu
            break;
        end
        [radarReadings, cameraReadings] = car.getSensorReadings();
        
        if ~car.checkInsidePosition(pose) % kontrola ci je automobil na mape
            fitInside = inf; % ak je automobil mimo mapy tak dostane pokutu, ktora ho zabije
%             fitInside = 1e9;
            break;
        end

        switch car.sensorMode % evaluacia podla typu senzoru
            case 1
                [out] = nn.evaluateOutput(radarReadings, [pi/4], weights, popIndex, geneIndex); % get output angle
            case 2
                [out] = nn.evaluateOutput(cameraReadings, [pi/4], weights, popIndex, geneIndex); % get output angle
            case 3
                [out] = nn.evaluateOutput([radarReadings, cameraReadings'], [pi/4], weights, popIndex, geneIndex); % get output angle
        end

        car = car.update(out(1), out(2));
        pose = [car.carPosition, car.headingAngle];

        switch map.checkCheckpoints(pose, checkpointsReached)
            case 1 % dosiahnutie spravneho checkpointu
%                 fit = fit - 1e2;
                fitChpt = fitChpt - 1e2; % odmena za spravny checkpoint
                checkpointsReached = checkpointsReached + 1;
            case 2 % dosiahnutie nespravneho checkpointu
%                 fit = fit + 0.5e2;
%                 fitChpt = fitChpt + 0.5e2;
        end

        checkpointsRemaining = map.checkpointCount - checkpointsReached;

        currentPosition = car.getCarOccupancy(0);

%         car.drawCar();

        if currentPosition ~= 0 % ak je pozicia na ciare tak dostane pokutu
%             fitPose = fitPose + 0.5e4;
           fitPose = fitPose + 1e3;
%            break;
%             fitPose = fitPose + 1e3;   
%             break;
        end
    end
    format long

    fit = step * (checkpointsRemaining+2) + fitPose + fitInside + fitChpt + fitFinish;
%     fit = (step + fitPose + fitInside) / (checkpointsReached+1) + fitChpt + fitFinish;
%     fit = (step + fitPose + fitInside) / (checkpointsReached+1) + fitChpt + fitFinish;

    fitSep =  [fitPose, step, fitChpt, fitFinish, fitInside, fit, checkpointsReached];
end

