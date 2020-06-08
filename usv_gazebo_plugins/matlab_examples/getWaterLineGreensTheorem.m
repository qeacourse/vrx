function [torque,d,CoM] = getWaterLineGreensTheorem(theta, L, CoM, densityRatioWeightedArea, allPoints, densityRatio, ballastLevel)
if nargin < 6
    densityRatio = 1/4;
end
if nargin < 7
    ballastLevel = -Inf;
end
ycom = CoM(1);
zcom = CoM(2);
mass = densityRatioWeightedArea*L*1000;%Kg

% define the direction of gravity
down = [0, 0, -1];

% rotate the boat about the origin to match the Gazebo simulator
[y_allPointsRotated,z_allPointsRotated]=rotate(allPoints(:,1),allPoints(:,2),theta,0,0);
[d,ycob,zcob] = fastWaterline(y_allPointsRotated,z_allPointsRotated,L,mass);
% find the torque
rotated_com = [cosd(theta) sind(theta);...
               -sind(theta) cosd(theta)]*[ycom; zcom];
torque = cross([0,ycob-rotated_com(1),zcob-rotated_com(2)],-down*mass*9.8);%Nm
torque = torque(1);
end

function [d,ycob,zcob] = fastWaterline(y,z,L,mass)
area_displaced_at_eq = mass/L/1000;
[d,ycob,zcob] = cumulativeArea([y z],area_displaced_at_eq);
end

% Define a rotation about a point (ycom,zcom)
function [yy,zz] = rotate(y,z,theta,ycom,zcom)
yy = ycom + cosd(theta)*(y-ycom) + sind(theta)*(z-zcom);
zz = zcom - sind(theta)*(y-ycom) + cosd(theta)*(z-zcom);
end
