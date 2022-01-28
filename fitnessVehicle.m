function [fit, poses] = fitnessVehicle(pop, hiddenLayer, params, map, lidar, pose, maxRange, input, currentGen)
    velocity = 1;
    fit = 0;

    checkPointsReached = 0;
    currentStep = 1;
    alreadyBadSteps = 0;

    poses = zeros(1000,3);

    while fit < 1000 && checkFinish(pose, checkPointsReached) ~= 1
        [W1, W2, W3, B1, B2] = calculateWeights(pop, params, hiddenLayer);
        [angle] = evalOutput(W1, W2, W3, B1, B2, input, maxRange); % get output angle
 
        [pose, input] = moveAndGenData(lidar, pose, velocity, angle, maxRange);
        
        poses(currentStep,:,:) =  pose';

        currentPosition = getOccupancy(map, [pose(1,1), pose(2,1)]);

% 130 krokov 2.checkpoint, aj 3.checkpoint, 200 krokov 4.checkpoint

        checkPointsReached = checkPointsReached + getCheckPointRes(pose, checkPointsReached);
        if currentStep > 20 && checkPointsReached == 0
            fit = fit + 1000;
        end
          
        if currentStep > 160 && checkPointsReached == 1
            fit = fit + 100;
        end

        if currentStep > 290 && checkPointsReached == 2
            fit = fit + 100;
        end
           
        if currentStep > 420 && checkPointsReached == 3
            fit = fit + 100;
        end

        if currentStep > 620 && checkPointsReached == 4
            fit = fit + 100;
        end

        if (currentPosition == 0) 
            fit = fit + 1; % made a step, increment by one
        else
            alreadyBadSteps = alreadyBadSteps + 1;
            fit = fit + 100 * alreadyBadSteps;  % the car has crashed, fit = penalty
        end
        currentStep = currentStep + 1;
    end
    % visualize the change in position and angle
    % viz(pose,ranges)
end