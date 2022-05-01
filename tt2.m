% ----------- %
close all
clc
clear
% ----------- %
%%
figure('Position', [100, 100, 800, 500]);

variant = 3;
scale = 1;
sensorMode = 1;
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
        xCar = 205 * scale;
        yCar = 48 * scale;
        angle = pi/4;
        maxSteps = round(1000 * scale);
        finish = [330 340 340 330 330, 340 340 372 372 340] / scale;
        checkpoints = [220 230 230 220 220,  73 73 41 41 73;
                       237 237 269 269 237, 120 130 130 120 120;
                       298 298 330 330 298, 190 200 200 190 190;
                       248 238 238 248 248, 234 234 202 202 234;
                       188 178 178 188 188, 234 234 202 202 234;
                       117 117 149 149 117, 200 190 190 200 200;
                       117 117 149 149 117, 140 130 130 140 140;
                       69 69 101 101 69, 130 140 140 130 130;
                       69 69 101 101 69, 190 200 200 190 190;
                       69 69 101 101 69, 250 260 260 250 250;
                       133 133 165 165 133, 308 318 318 308 308;
                       205 215 205 195 205, 365 363 331 334 365;
                       245 255 255 245 245, 313 313 281 281 313;];
end

map = Map(img, scale, checkpoints, finish, maxSteps);
hold on

car = Car(xCar, yCar, angle, map, sensorMode);
car.drawCar();
b = car.update(0, 1);
c = b.update(0, 1);

