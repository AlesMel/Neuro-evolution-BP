classdef Map
    %MAP Summary of this class goes here
    %   Detailed explanation goes here

    properties
        image
        bwImage
        map
        mapSize = 0;
        scale = 1;
        checkpoints = [];
        finish = []
        checkpointCount = 0;
        checkpointsEdges = [];
        maxSteps = 0;
    end


    methods
        function obj = Map(image, scale, checkpoints, finish, maxSteps)
            obj = obj.processImage(image);
            obj = obj.rescaleMap(scale);
            obj = obj.insertCheckpoints(checkpoints);
            obj = obj.insertFinish(finish);
            obj.maxSteps = maxSteps;
        end

        function obj = rescaleMap(obj, scale)
            obj.image = imresize(obj.image, scale);
            map = imresize(obj.bwImage, scale);
            obj.mapSize = length(map);
            obj.map = createMap(map);
        end

        function obj = insertCheckpoints(obj, checkpoints)
            if ~isempty(checkpoints)
                obj.checkpoints = checkpoints;
                obj.checkpointCount = length(checkpoints(:,1));
            end
        end

        function drawCheckpoints(obj)
            for i = 1:obj.checkpointCount
                obj.checkpointsEdges(i, :) = [obj.checkpoints(i, 1) obj.checkpoints(i,6) obj.checkpoints(i, 4) obj.checkpoints(i,9)];
                fill(obj.checkpoints(i,1:5), obj.checkpoints(i, 6:end),'g', 'FaceAlpha', 0.2)
                 plot([obj.checkpointsEdges(i,1) obj.checkpointsEdges(i,3)], [obj.checkpointsEdges(i,2) obj.checkpointsEdges(i,4)], 'Color',[1 0 1, 0.5] ,'LineWidth', 2)
                
            end

        end

        function drawFinish(obj)
            finishEdges(:) = [obj.finish(1, 1) obj.finish(1,6) obj.finish(1, 4) obj.finish(1,9)];
            fill(obj.finish(1, 1:5), obj.finish(1, 6:end),'b')
            plot([finishEdges(1,1) finishEdges(1,3)], [finishEdges(1,2) finishEdges(1,4)], 'r', 'LineWidth', 2)
        end

        function obj = insertFinish(obj, finish)
            if ~isempty(finish)
                obj.finish = finish;
            end
        end

        function occupancy = checkOccupancy(obj, car, pose) 
            occupancy = getOccupancy(obj.map, [pose(1), pose(2)]) || ...
            getOccupancy(obj.map, [pose(1)+car.carWidth/2, pose(2)]) || ...
            getOccupancy(obj.map, [pose(1)-car.carWidth/2, pose(2)]) || ...
            getOccupancy(obj.map, [pose(1)+car.carWidth/2, pose(2)-car.carLength])|| ...
            getOccupancy(obj.map, [pose(1)-car.carWidth/2, pose(2)-car.carLength]);
        end


        function finished = checkFinish(obj, pose)
            finished = 0;

            PX = pose(1);
            PY = pose(2);

            [in, on] = inpolygon(PX, PY, obj.finish(1,1:5), obj.finish(1, 6:end));

            if (in > 0 || on > 0)
                finished = 1;
            end
        end

        function inside = checkInside(obj, pose)
            inside = 0;
            if pose(1) >= obj.mapSize || pose(1) <= 0
                inside = 1;
            end
            if pose(2) >= obj.mapSize || pose(2) <= 0
                inside = 1;
            end
        end

        function [checkpointSol] = checkCheckpoints(obj, pose, checkpointsReached)

            PX = pose(1);
            PY = pose(2);
            checkpointSol = 0;
            finishLeft = 0;

            for chpt = 1:length(obj.checkpoints(:,1))
                nextChpt = checkpointsReached + 1;

                if nextChpt <= obj.checkpointCount
                    checkpoint = obj.checkpoints(chpt, :); % current checkpoint
                elseif nextChpt == obj.checkpointCount + 1
                    checkpoint = obj.finish;
                    finishLeft = 1;
                end
                if nextChpt <= obj.checkpointCount + 1
                    [in, on] = inpolygon(PX, PY, checkpoint(1,1:5), checkpoint(1, 6:end));
    
                    if (in > 0 || on > 0) && ((nextChpt) == chpt || finishLeft == 1)
                        checkpointSol = 1;
                    elseif (in > 0 || on > 0)
                        checkpointSol = 2;
                    end
                end
            end
        end
        
        function obj = processImage(obj, image)
            obj.image = imread(image);
            grayImage = rgb2gray(obj.image);
            obj.bwImage = grayImage > 123;
            obj.image = flip(obj.image, 1); % we need to flip because image does have a reversed y axis direction
        end

    end

    methods (Static)
    end
end

function map = createMap(map)
    map = binaryOccupancyMap(map);
end

