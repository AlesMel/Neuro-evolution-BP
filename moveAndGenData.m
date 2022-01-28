function [pose, ranges] = moveAndGenData(lidar, pose, velocity, angle, maxRange)
    % function that generates data and moves the vehicle
    cosinus = round(cos(angle),2);
    sinus = round(sin(angle),2);

    pose = pose + [velocity * cosinus; velocity * sinus; angle];
    ranges = lidar(pose);
    [row, col] = find(isnan(ranges));
    ranges(row, col) = maxRange;
end