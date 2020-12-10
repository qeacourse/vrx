function teeterTotter(masses, positions, massOfBoard, pivotOffset, pivotJointType)
% simulation of the teeter totter.  The masses are the massses of each object
% (or kid if you will) in kg.  The positions are the linear position along
% the beam in meters (valid positions are in the range of -2m,2m
if nargin < 3
    massOfBoard = 0;
end
if nargin < 4
    pivotOffset = 0;
end
if nargin < 5
    pivotJointType = 'continuous';
end
if strcmp(pivotJointType, 'fixed') == 1
    pivotMass = 0;
else
    pivotMass = 100;
end
if isvector(positions)
    if iscolumn(positions)
        positions = positions';
    end
    positions(end+1,:) = 0;
    boardWidth = 1;
else
    boardWidth = 4;
end
doc = com.mathworks.xml.XMLUtils.createDocument('robot');

teeterTotterThickness = 0.1;
teeterTotterHeight = 0.75;
robotElem = doc.getDocumentElement();
robotElem.setAttribute('name','teeter_totter');
spawnBox(doc, 'pivot', pivotMass, 0.1, 0.1, teeterTotterHeight);
spawnBox(doc, 'board', massOfBoard, boardWidth, 4, teeterTotterThickness, 'Gazebo/DarkMagentaTransparent');

for i = 1 : length(masses)
    % mass = volume*density
    % volume = pi*r^3 (assume equal radius and height)
    % r = (mass/(pi*density))^(1/3)
    density = 1000; % assume 1000 kg/m^3 (density of water)
    radiusAndHeight = (masses(i)/(pi*density))^(1/3);
    blueCylinder(doc, ['weight_',num2str(i)], masses(i), radiusAndHeight, radiusAndHeight);
    connectWithFixedJoint(doc, ['weight_',num2str(i),'_joint'], 'board', ['weight_',num2str(i)], positions(2,i), positions(1,i), teeterTotterThickness);
end
% the offset is negated due to the directionality of the dummy link that is added
connectPivot(doc, 'pivotlink', pivotJointType, 'pivot', 'board', 0, 0, teeterTotterHeight, 0, -pivotOffset, 0);
spawnModel('teeter_totter',xmlwrite(robotElem),0,0,0);
end