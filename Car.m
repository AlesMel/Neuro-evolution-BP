classdef Car
    %Class that creates actor (Car)
    %   Detailed explanation goes here
    properties
        speed = 0
        multiplyParameters = 200;
        multiplication = 7; % how much do we have to scale the car and sensors
        maxSpeed
        minSpeed
        acceleration
        brakeSpeed
        reverseSpeed
        idleSlowDown

        turn_speed = 0;
        turn_speed_max = 60;
        turn_speed_acceleration = 30;
        turn_idle_slow_down = 60;
        min_turn_amount =  5;

        carWidth
        carLength
        carWheelBase
        carWheelWidth
        carWheelLength
        carWindShieldLength
        carWindShieldWidth
        carHoodLength
        carHoodMidWidth
        carHoodWidth
        carTrunkLength
        carTrunkWidth
        carWindowLength
        carWindowWith
        carLightsWidth
        carLightsLength

        xPosition {mustBeNumeric}
        yPosition {mustBeNumeric}

        carPosition {mustBeNumeric}
        carCenter

        steerAngle = 0;
        headingAngle = 0;

        carBody = zeros(2,4);
        carPose = 0;
        wheelsPose = 0;
        carLines

        dt = 0.001;

        sensorMaxRange = 20;
        sensorBeams = 10;

        sensorAngles = linspace(-pi/2, pi/2, 10)
        sensorLines = zeros(10, 4)
        sensorReadings

        sensorMode = 0;

        camera
        cameraMaxRange;
        cameraReadings
        cameraMaxReadings = 10;

        map
        mapObject

        frontWheels
        backWheels
    end

    methods
        function obj = Car(xPosition, yPosition, headingAngle, map, sensorMode)
            obj = obj.resizeVars(obj.multiplyParameters, obj.multiplication);
            obj.xPosition = xPosition;
            obj.yPosition = yPosition;
            obj.headingAngle = headingAngle;
            obj.sensorMode = sensorMode;
            obj.carPosition = [xPosition yPosition];
            obj = obj.updateCarBody();
            obj = obj.createWheels();
            obj = obj.updateSensor();
            obj = obj.processMap(map);
            [obj.sensorReadings, obj.cameraReadings] = obj.getSensorReadings();
        end

        function obj = resizeVars(obj, multiplyParameters, multiplication)
            obj.maxSpeed = 20*multiplyParameters;
            obj.minSpeed = -5*multiplyParameters;
            obj.acceleration = 2*multiplyParameters;
            obj.brakeSpeed = 5*multiplyParameters;
            obj.reverseSpeed = 5*multiplyParameters;
            obj.idleSlowDown = 5*multiplyParameters;

            obj.sensorMaxRange = 20 * multiplication / 3;
            obj.cameraMaxRange = 2 * multiplication / 4;

            obj.carWidth = 1.85*multiplication;
            obj.carLength = 4.76*multiplication;
            obj.carWheelBase = 2.8*multiplication;
            obj.carWheelWidth = 0.195*multiplication;
            obj.carWheelLength = 0.48*multiplication;

            obj.carWindShieldLength = 0.5 * multiplication;
            obj.carWindShieldWidth = 1.5 * multiplication;
            obj.carHoodLength = 1 * multiplication;
            obj.carHoodMidWidth = 0.1 * multiplication;
            obj.carHoodWidth = 0.5 * multiplication;
            obj.carTrunkLength = 0.01 * multiplication;
            obj.carTrunkWidth = -1.5 * multiplication;
            obj.carWindShieldLength = 0.5 * multiplication;
            obj.carWindShieldWidth = 1.5 * multiplication;

            obj.carWindowLength = 1.75 * multiplication;
            obj.carWindowWith = 0.2 * multiplication;

            obj.carLightsLength = 0.12 * multiplication;
            obj.carLightsWidth = 0.4 * multiplication;

        end

        function obj = update(obj, angle, forwardAmount)
            obj = obj.moveCar(angle);
            if forwardAmount > 0
                obj.speed = obj.speed + forwardAmount * obj.acceleration;
            elseif forwardAmount < 0
                if obj.speed > 0
                    obj.speed = obj.speed + forwardAmount * obj.brakeSpeed;
                else
                    obj.speed = obj.speed + forwardAmount * obj.reverseSpeed;
                end
            elseif forwardAmount == 0
                if obj.speed > 0
                    obj.speed = obj.speed - obj.idleSlowDown;
                end
                if obj.speed < 0
                    obj.speed = obj.speed + obj.idleSlowDown;
                end
            end

            obj.speed = min(max(obj.speed, obj.minSpeed), obj.maxSpeed);
            %
            %             if obj.speed < 0
            %                 turn_amount = turn_amount * -1.0;
            %             end
            %
            %             if turn_amount > 0 || turn_amount < 0
            %                 % changing turn direction
            %                 if (obj.turn_speed > 0 && turn_amount < 0) || (obj.turn_speed < 0 && turn_amount > 0)
            %                     obj.turn_speed = turn_amount * obj.min_turn_amount;
            %                 end
            %                 obj.turn_speed = obj.turn_speed + turn_amount * obj.turn_speed_acceleration;
            %             elseif turn_amount == 0
            %                 if obj.turn_speed > 0
            %                     obj.turn_speed = obj.turn_speed - obj.turn_idle_slow_down;
            %                 end
            %                 if obj.turn_speed < 0
            %                     obj.turn_speed = obj.turn_speed + obj.turn_idle_slow_down;
            %                 end
            %                 if obj.turn_speed > -1 && obj.turn_speed < 1
            %                     obj.turn_speed = 0;
            %                 end
            %             end
            %
            %             obj.turn_speed = min(max(obj.turn_speed, -obj.turn_speed_max), obj.turn_speed_max);
        end

        function obj = moveCar(obj, radians)
            obj.steerAngle = radians;
            obj = obj.createWheels();
            obj = obj.moveWheels();
            obj.carPosition = (obj.frontWheels + obj.backWheels) / 2;
            obj.headingAngle = atan2(obj.frontWheels(2) - obj.backWheels(2), obj.frontWheels(1) - obj.backWheels(1));
            obj = obj.updateCarBody();
            obj = obj.updateSensor();
            [obj.sensorReadings, obj.cameraReadings] = obj.getSensorReadings();
        end

        function [obj] = drawCar(obj)
            obj.carCenter(1) = obj.carPosition(1) - (obj.carLength/2) * cos(obj.headingAngle);
            obj.carCenter(2) = obj.carPosition(2) - (obj.carLength/2) * sin(obj.headingAngle);
            obj = obj.drawWheels();

            obj.carLines = drawRectangle(obj.carCenter, obj.headingAngle, obj.carLength, obj.carWidth, 'r', "k", 0);

            obj = obj.drawSensor();
            obj = obj.drawCarComponents();
            obj.drawSensorReadings();
            obj.getCarOccupancy(1);
            hold off
%             ylabel('Y [m x10]')
%             xlabel('X [m x10]')
            set(gca,'YDir','reverse')
            %             xlim([0, 100])
            %             ylim([0, 100])
        end

        function obj = updateCarBody(obj)
            % car properties
            x = obj.carPosition(1);
            y = obj.carPosition(2);
            w = obj.carWidth;
            l = obj.carLength;

            obj.carBody = [x-w/2 y+l/2; x+w/2 y+l/2; x+w/2 y-l/2; x-w/2 y-l/2];
        end

        function obj = createWheels(obj)
            obj.frontWheels = obj.carPosition + obj.carWheelBase/2 * [cos(obj.headingAngle) sin(obj.headingAngle)];
            obj.backWheels = obj.carPosition - obj.carWheelBase/2 * [cos(obj.headingAngle) sin(obj.headingAngle)];
        end

        function obj = moveWheels(obj)
            obj.frontWheels = obj.frontWheels + obj.speed * obj.dt * [cos(obj.headingAngle + obj.steerAngle) sin(obj.headingAngle + obj.steerAngle)];
            obj.backWheels = obj.backWheels + obj.speed * obj.dt * [cos(obj.headingAngle) sin(obj.headingAngle)];
        end

        function obj = drawWheels(obj)
            % Left front wheel
            centers = rotate(obj.carWheelBase/2, obj.carWidth/2, obj.headingAngle);
            centers = centers + obj.carCenter;
            angle = obj.headingAngle + obj.steerAngle;
            if ~isempty(obj.map)
%                  show(obj.map)
                imshow(obj.mapObject.image);
                hold on
                obj.mapObject.drawCheckpoints();
                obj.mapObject.drawFinish();
            end
            drawRectangle(centers, angle, obj.carWheelLength, obj.carWheelWidth, "k", "k", 0);

            % Right front wheel
            centers = rotate(obj.carWheelBase/2, -obj.carWidth/2, obj.headingAngle);
            centers = centers + obj.carCenter;
            angle = obj.headingAngle + obj.steerAngle;
            drawRectangle(centers, angle, obj.carWheelLength, obj.carWheelWidth, "k", "k", 0);
            % Left rear wheel
            centers = rotate(-obj.carWheelBase/2, obj.carWidth/2, obj.headingAngle);
            centers = centers + obj.carCenter;
            angle = obj.headingAngle;
            drawRectangle(centers, angle, obj.carWheelLength, obj.carWheelWidth, "k", "k", 0);
            % Right rear wheel
            centers = rotate(-obj.carWheelBase/2, -obj.carWidth/2, obj.headingAngle);
            centers = centers + obj.carCenter;
            angle = obj.headingAngle;
            drawRectangle(centers, angle, obj.carWheelLength, obj.carWheelWidth, "k", "k", 0);
        end

        function obj = drawCarComponents(obj)
            %             % roof
            %             centers = obj.car_center;
            %             draw_rectangle(centers, obj.heading_angle, 2, 1, [0.5020    0.5020    0.5020], 'k', 0);
            %             fill_color = [0.8196    1.0000    0.9765];
            fill_color = 'k';
            frame_color = [0.5020    0.5020    0.5020];

            % rear windshield
            centers = rotate(-obj.carLength/2+obj.carLength*0.1681, -obj.carWidth/2+obj.carWidth/2, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, obj.carWindShieldLength, obj.carWindShieldWidth, fill_color, frame_color, 1);

            % front windshield
            centers = rotate(obj.carLength/2-obj.carLength*0.3151, -obj.carWidth/2+obj.carWidth/2, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, obj.carWindShieldLength, obj.carWindShieldWidth, fill_color, frame_color, 2);

            % right window
            centers = rotate(obj.carLength-obj.carLength*1.07, -obj.carWidth/2+obj.carWidth*0.1351, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, obj.carWindowLength, obj.carWindowWith, fill_color, frame_color, 3);

            % left window
            centers = rotate(obj.carLength-obj.carLength*1.07, obj.carWidth/2-obj.carWidth*0.1351, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, -obj.carWindowLength, -obj.carWindowWith, fill_color, frame_color, 4);

            % left lights
            centers = rotate(obj.carLength/2-.06, obj.carWidth/2 - obj.carWidth*0.1892, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, -obj.carLightsLength, -obj.carLightsWidth, 'k', frame_color, 0);

            % right lights
            centers = rotate(obj.carLength/2-.06, -obj.carWidth/2 + obj.carWidth*0.1892, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, -obj.carLightsLength, obj.carLightsWidth, 'k', frame_color, 0);

            % %             right lights
            % %             centers = rotate(obj.car_length/2-.06, -obj.car_width/2 + 0.95, obj.heading_angle);
            % %             centers = centers + obj.car_center;
            % %             draw_rectangle(centers, obj.heading_angle, -0.12, 0.5, 'k', 'k', 0);

            % hood
            centers = rotate(obj.carLength/2-obj.carLength*0.13, -obj.carWidth/2+obj.carWidth/2, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, obj.carHoodLength, obj.carHoodMidWidth, 'k', 'r', 0);

            centers = rotate(obj.carLength/2-obj.carLength*0.13, -obj.carWidth/2+obj.carWidth*0.324, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, obj.carHoodLength, obj.carHoodWidth, 'k', 'r', 5);

            centers = rotate(obj.carLength/2-obj.carLength*0.134, +obj.carWidth/2-obj.carWidth*0.324, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, obj.carHoodLength, -obj.carHoodWidth, 'k', 'r', 6);

            % trunk
            centers = rotate(obj.carLength*(-1/2+0.084),  -obj.carWidth/2+obj.carWidth/2, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, obj.carTrunkLength, obj.carTrunkWidth, 'k', 'k', 0);

            centers = rotate(obj.carLength*(-1/2+0.064),  -obj.carWidth/2+obj.carWidth/2, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, obj.carTrunkLength, -obj.carTrunkWidth, 'k', 'k', 0);

            centers = rotate(obj.carLength*(-1/2+0.044),  -obj.carWidth/2+obj.carWidth/2, obj.headingAngle);
            centers = centers + obj.carCenter;
            drawRectangle(centers, obj.headingAngle, obj.carTrunkLength, obj.carTrunkWidth, 'k', 'k', 0);
        end

        function occupancy = getCarOccupancy(obj, show)
            pose = obj.carPosition;
            % check the front points of the vehicle
            o1 = rotate(0, obj.carWidth/2, obj.headingAngle) + pose;
            o2 = rotate(0, 0, obj.headingAngle) + pose; % mid
            o3 = rotate(0, -obj.carWidth/2, obj.headingAngle) + pose;

            % check the rear points of the vehicle
            o4 = rotate(-obj.carLength, 0, obj.headingAngle) + pose; % mid
            o5 = rotate(-obj.carLength, obj.carWidth/2, obj.headingAngle) + pose; % right
            o6 = rotate(-obj.carLength, -obj.carWidth/2, obj.headingAngle) + pose; % left

            % if some of it touched a black pixel set occupancy to one
%             occupancy = getOccupancy(obj.map, o2); % chcek only the mid
%             allowing the car to use curbes
            occupancy = getOccupancy(obj.map, o1) || getOccupancy(obj.map, o2) || getOccupancy(obj.map, o3);
%             occupancy = getOccupancy(obj.map, o1) || getOccupancy(obj.map, o2) || getOccupancy(obj.map, o3) || getOccupancy(obj.map, o4) || getOccupancy(obj.map, o5) || getOccupancy(obj.map, o6);
% 
            if show
                plot(o1(1), o1(2), 'bO', 'MarkerSize', 5)
                plot(o2(1), o2(2), 'bO', 'MarkerSize', 5)
                plot(o3(1), o3(2), 'bO', 'MarkerSize', 5)
                plot(o4(1), o4(2), 'bO', 'MarkerSize', 5)
                plot(o5(1), o5(2), 'bO', 'MarkerSize', 5)
                plot(o6(1), o6(2), 'bO', 'MarkerSize', 5)
            end

        end

        function obj = updateSensor(obj)
            switch obj.sensorMode
                case 1
                    obj = obj.updateRadarSensor();
                case 2
                    obj = obj.updateCameraSensor();
                case 3
                    obj = obj.updateRadarSensor();
                    obj = obj.updateCameraSensor();
            end
        end

        function obj = updateRadarSensor(obj)
            for i = 1:(obj.sensorBeams)
                r_matrix = rotate(obj.sensorMaxRange * cos(obj.sensorAngles(i)), obj.sensorMaxRange * sin(obj.sensorAngles(i)), obj.headingAngle);
                r_matrix = r_matrix + obj.carPosition;
                obj.sensorLines(i,:) = [obj.carPosition(1,1) obj.carPosition(1,2), r_matrix(1) r_matrix(2)];
            end
        end

        function obj = updateCameraSensor(obj)
            r_matrix = rotate([0, obj.cameraMaxRange*7, obj.cameraMaxRange*10, obj.cameraMaxRange*7],[0, obj.cameraMaxRange, 0, -obj.cameraMaxRange] * obj.multiplication, obj.headingAngle);
            obj.camera = r_matrix + obj.carPosition;
        end

        function obj = drawRadar(obj)
            for i = 1:(obj.sensorBeams)
                line([obj.sensorLines(i,1) obj.sensorLines(i,3)], [obj.sensorLines(i,2) obj.sensorLines(i,4)], 'color', 'green')
            end
        end

        function obj = drawCamera(obj)
            cam = polyshape(obj.camera(:,1), obj.camera(:,2));
            plot(cam)
        end

        function obj = drawSensor(obj)
            switch obj.sensorMode
                case 1
                    obj.drawRadar();
                case 2
                    obj.drawCamera();
                case 3
                    obj.drawRadar();
                    obj.drawCamera();
                case 4
            end
        end

        function [sensorReadings, cameraReadings] = getSensorReadings(obj)
            cameraReadings = 0;
            sensorReadings = 0;
            switch obj.sensorMode
                case 1
                    sensorReadings = obj.processRadarReadings();
                case 2
                    cameraReadings = obj.processCameraReadings();
                case 3
                    sensorReadings = obj.processRadarReadings();
                    cameraReadings = obj.processCameraReadings();
                case 4
            end
        end

        function [x, y] = getCameraReadings(obj)
            c = obj.camera;
            cam_points = [1/2*(1/2*(c(1,1) + c(2,1))+ c(1,1))     1/2*(1/2*(c(1,2) + c(2,2))+ c(1,2));
                1/2*(1/2*(c(1,1) + c(2,1))+ c(2,1))     1/2*(1/2*(c(1,2) + c(2,2))+ c(2,2));
                1/2*(1/2*(c(2,1) + c(3,1)) + c(3,1))    1/2*(1/2*(c(2,2) + c(3,2)) + c(3,2));
                1/2*(1/2*(c(2,1) + c(3,1)) + c(2,1))    1/2*(1/2*(c(2,2) + c(3,2)) + c(2,2));
                1/2*(1/2*(c(3,1) + c(4,1)) + c(4,1))    1/2*(1/2*(c(3,2) + c(4,2)) + c(4,2));
                1/2*(1/2*(c(3,1) + c(4,1)) + c(3,1))    1/2*(1/2*(c(3,2) + c(4,2)) + c(3,2));
                1/2*(1/2*(c(4,1) + c(1,1)) + c(4,1))    1/2*(1/2*(c(4,2) + c(1,2)) + c(4,2));
                1/2*(1/2*(c(4,1) + c(1,1)) + c(1,1))    1/2*(1/2*(c(4,2) + c(1,2)) + c(1,2));
                (1/2*(1/2*(c(2,1) + c(3,1)) + c(3,1)) + 1/2*(1/2*(c(1,1) + c(2,1))+ c(1,1)))/2   (1/2*(1/2*(c(2,2) + c(3,2)) + c(3,2)) + 1/2*(1/2*(c(1,2) + c(2,2))+ c(1,2)))/2;
                (1/2*(1/2*(c(3,1) + c(4,1)) + c(3,1)) + 1/2*(1/2*(c(4,1) + c(1,1)) + c(1,1)))/2 (1/2*(1/2*(c(3,2) + c(4,2)) + c(3,2)) + 1/2*(1/2*(c(4,2) + c(1,2)) + c(1,2)))/2;];
            x = cam_points(:,1);
            y = cam_points(:,2);
        end

        function sensor_readings = processRadarReadings(obj)
            if obj.checkInsidePosition([obj.carPosition obj.headingAngle])
                sensor_positions = rayIntersection(obj.map, [obj.carPosition obj.headingAngle], obj.sensorAngles, obj.sensorMaxRange);
                for i = 1:obj.sensorBeams
                    x = sensor_positions(i,1);
                    y = sensor_positions(i,2);

                    if isnan(x) || isnan(y)
                        sensor_readings(i) = obj.sensorMaxRange;
                    else
                        sensor_readings(i) = sqrt((x-obj.carPosition(1))^2 + (y-obj.carPosition(2))^2);
                    end
                end
            else
                sensor_readings = zeros(obj.sensorBeams, 1);
            end
        end

        function camera_readings =  processCameraReadings(obj)
            [x, y] = obj.getCameraReadings();
            camera_readings = getOccupancy(obj.map, [x, y]);
        end

        function obj = drawSensorReadings(obj)
            switch obj.sensorMode
                case 1
                    obj.drawRadarReadings();
                case 2
                    obj.drawCameraReadings();
                case 3
                    obj.drawRadarReadings();
                    obj.drawCameraReadings();
                case 4
            end
        end

        function drawRadarReadings(obj)
            if obj.checkInsidePosition([obj.carPosition obj.headingAngle])
                sensor_positions = rayIntersection(obj.map, [obj.carPosition obj.headingAngle], obj.sensorAngles, obj.sensorMaxRange);
                plot(sensor_positions(:,1), sensor_positions(:,2), 'rX')
            end
        end

        function drawCameraReadings(obj)
            [x, y] = obj.getCameraReadings();
            plot(x, y, 'gX')
        end

        function result = checkInsidePosition(obj, pose)
            result = 1;
            if ~isempty(obj.map)
                map_x = obj.map.XLocalLimits;
                map_y = obj.map.YLocalLimits;

                if pose(1) >= map_x(2) || pose(1) <= map_x(1)
                    result = 0;
                end
                if pose(2) >= map_y(2) || pose(2) <= map_y(1)
                    result = 0;
                end
            end
        end

        function obj = processMap(obj, map)
            if ~isempty(map)
                obj.mapObject = map;
                obj.map = map.map;
            end
        end

    end

    methods (Static)
    end
end

function rectangle_lines = drawRectangle(center, angle, length, width, color, edgeColor, displayOption)
    x = center(1);
    y = center(2);
    
    if displayOption == 0
        x_car = [x   x+length   x+length   x         x];
        y_car = [y   y          y+width    y+width   y];
    elseif displayOption == 1
        x_car = [x   x+length   x+length   x         x];
        y_car = [y   y+0.3          y+width-0.3    y+width   y];
    elseif displayOption == 2
        x_car = [x   x+length   x+length   x         x];
        y_car = [y+0.3   y          y+width    y+width-0.3   y+0.3];
    elseif displayOption == 3
        x_car = [x-0.3   x+length+0.3   x+length   x       x-0.3];
        y_car = [y   y          y+width    y+width   y];
    elseif displayOption == 4
        x_car = [x+0.3   x+length-0.3   x+length   x       x+0.3];
        y_car = [y   y          y+width    y+width   y];
    elseif displayOption == 5
        x_car = [x   x+length-0.5   x+length   x       x];
        y_car = [y   y          y+width    y+width   y];
    elseif displayOption == 6
        x_car = [x   x+length-0.5   x+length   x       x];
        y_car = [y   y          y+width    y+width   y];
    end
    
    % 1. transform into coordinate system
    translated(1,:) = x_car - x;
    translated(2,:) = y_car - y;
    
    % 2. now we rotate
    rotated = rotate(translated(1,:), translated(2,:), angle)';
    
    % 3. transform it back
    XY(1,:) = rotated(1,:) + x;
    XY(2,:) = rotated(2,:) + y;
    
    translated = rotate(length/2, width/2, angle);
    
    X = XY(1,:) - translated(1);
    Y = XY(2,:) - translated(2);
    
    rectangle_lines =   [X(1) Y(1) X(2) Y(2);
        X(2) Y(2) X(3) Y(3);
        X(3) Y(3) X(4) Y(4);
        X(4) Y(4) X(5) Y(5)];
    
    rect = fill(X, Y, 'w');
    set(rect, 'FaceColor', color, 'EdgeColor', edgeColor, 'LineWidth', 1);
end


function rotatedObject = rotate(x, y, angle)
    rotMatrix = [cos(angle) -sin(angle);
        sin(angle) cos(angle)];
    rotatedObject = (rotMatrix * [x; y])';
end
