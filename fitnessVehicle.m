function [fit, poses] = fitnessVehicle(pop, nnDet, cmDet)
    velocity = 1;
    fit = 0;

    chptReached = 0;
    currentStep = 1;
    finished = 0;

    poses = zeros(1000,3);
    
    % extract necessary values
    map = cmDet{1,1};
    lidar = cmDet{2,1};
    pose = cmDet{3,1};
    input = cmDet{4,1};
    maxRange = cmDet{5,1};
    checkpoints = cmDet{6,1};
    numChpts = cmDet{7,1};
    mapSize = cmDet{8,1};

    params = nnDet{1,1};
    hiddenLayer = nnDet{2,1};

    while currentStep < 1000 && finished ~= 1
        [finished, fit] = checkFinish(pose, chptReached, fit, numChpts);

        currentStep = currentStep + 1;

        [W1, W2, W3, B1, B2] = calculateWeights(pop, params, hiddenLayer);
        [angle] = evalOutput(W1, W2, W3, B1, B2, input, maxRange); % get output angle
 
        [pose, input] = moveAndGenData(lidar, pose, velocity, angle, maxRange);
        poses(currentStep,:,:) =  pose';
        
        % determine if we are on the wall or on the road
        currentPosition = getOccupancy(map, [pose(1,1), pose(2,1)]);

        [fit, chptReached] = checkpointsCheck(checkpoints, chptReached, pose, fit);
        
        if currentStep > 5
            fit = checkStuck(poses(currentStep - 5: currentStep, 1:2, :), fit);
        end

        if currentPosition ~= 0
            fit = fit + 100;
        end

        if checkInside(pose, mapSize) ~= 0
            fit = fit + 100000;
            break;
        end
        
        fit = fit + 1;
    end
    % visualize the change in position and angle
    % viz(pose,ranges)
end