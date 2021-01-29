function spawnMyBoat(stlFileName, mass, centerOfMass, Ixx, Iyy, Izz)
if nargin < 1
    % this is a tester boat we've used
    stlFileName = 'boat_keel.STL';
    mass = 0.236; % kg
    % hacking the center of mass
    centerOfMass = [0, 0, 0.0457]; % x, y, z (meters)
    Ixx = 1.99e-4;
    Iyy = 5.531e-4;
    Izz = 5.589e-4;
end

Ixy = 0;
Iyz = 0;
Ixz = 0;

num2strPrecision = 10;
linearDrag = 2;
angularDrag = 5;

T = stlread(stlFileName);

biggestDimension = max(max(T.Points) - min(T.Points));
if biggestDimension > 1.0
    disp('Autoscaling mesh to units of meters from millimeters.');
    disp("We're going to need a smaller boat.");
    T = triangulation(T.ConnectivityList, T.Points/1000);
end
if min(T.Points(:,1)) >= 0 | min(T.Points(:,2)) >= 0
    error('When exporting your STL, make sure to check the option "Do not translate STL output data to positive space."');
end

[~,name,suffix] = fileparts(stlFileName);
modelDir = fullfile(tempdir, name);
mkdir(modelDir);
meshDir = fullfile(modelDir,'meshes');
mkdir(meshDir);

updatedMeshFileName = fullfile(meshDir, [name, suffix]);
stlwrite(T, updatedMeshFileName);
meshBoatSTLURI = stageMesh(stlFileName);
doc = com.mathworks.xml.XMLUtils.createDocument('sdf');
sdfElem = doc.getDocumentElement();
sdfElem.setAttribute('version', '1.5');
modelElem = doc.createElement('model');
sdfElem.appendChild(modelElem);
modelElem.setAttribute('name', 'customboat');
polyline = doc.createElement('link');
modelElem.appendChild(polyline);
polyline.setAttribute('name', 'link');
visual = doc.createElement('visual');
visual.setAttribute('name', java.util.UUID.randomUUID.toString());
polyline.appendChild(visual);
visualGeometry = doc.createElement('geometry');
visual.appendChild(visualGeometry);
meshElem = doc.createElement('mesh');
visualGeometry.appendChild(meshElem);
uriElem = doc.createElement('uri');
meshElem.appendChild(uriElem);
uriElem.setTextContent(meshBoatSTLURI);
visualMaterial = doc.createElement('material');
visual.appendChild(visualMaterial);
scriptMaterial = doc.createElement('script');
visualMaterial.appendChild(scriptMaterial);
uriMaterial = doc.createElement('uri');
scriptMaterial.appendChild(uriMaterial);
uriMaterial.setTextContent('file://media/materials/scripts/gazebo.material');
nameMaterial = doc.createElement('name');
scriptMaterial.appendChild(nameMaterial);
nameMaterial.setTextContent('Gazebo/WoodPallet')
collision = doc.createElement('collision');
collision.setAttribute('name', java.util.UUID.randomUUID.toString());
polyline.appendChild(collision);
collisionGeometry = doc.createElement('geometry');
collision.appendChild(collisionGeometry);
collisionMesh = doc.createElement('mesh');
collisionGeometry.appendChild(collisionMesh);
collisionUriElem = doc.createElement('uri');
collisionMesh.appendChild(collisionUriElem);
collisionUriElem.setTextContent(meshBoatSTLURI);

surface = doc.createElement('surface');
collision.appendChild(surface);
% TODO: factor out contact
contact = doc.createElement('contact');
surface.appendChild(contact);
collideBitmask = doc.createElement('collide_bitmask');
contact.appendChild(collideBitmask);
collideBitmask.setTextContent('0xffff');
friction = doc.createElement('friction');
surface.appendChild(friction);
odeNode = doc.createElement('ode');
friction.appendChild(odeNode);
mu = doc.createElement('mu');
odeNode.appendChild(mu);
mu.setTextContent('100');
mu2 = doc.createElement('mu2');
odeNode.appendChild(mu2);
mu2.setTextContent('50');


inertial = doc.createElement('inertial');
polyline.appendChild(inertial);
inertialPose = doc.createElement('pose');
inertial.appendChild(inertialPose);
inertialPose.setTextContent([num2str(centerOfMass(1), num2strPrecision),' ',num2str(centerOfMass(2), num2strPrecision),' ',num2str(centerOfMass(3), num2strPrecision),' 0 0 0']);
inertialMass = doc.createElement('mass');
inertial.appendChild(inertialMass);
inertialMass.setTextContent(num2str(mass, num2strPrecision));
inertia = doc.createElement('inertia');
inertial.appendChild(inertia);

ixx = doc.createElement('ixx');
inertia.appendChild(ixx);
ixx.setTextContent(num2str(Ixx, num2strPrecision));

ixy = doc.createElement('ixy');
inertia.appendChild(ixy);
ixy.setTextContent(num2str(Ixy, num2strPrecision));

ixz = doc.createElement('ixz');
inertia.appendChild(ixz);
ixz.setTextContent(num2str(Ixz, num2strPrecision));

iyy = doc.createElement('iyy');
inertia.appendChild(iyy);
iyy.setTextContent(num2str(Iyy, num2strPrecision));

iyz = doc.createElement('iyz');
inertia.appendChild(iyz);
iyz.setTextContent(num2str(Iyz, num2strPrecision));

izz = doc.createElement('izz');
inertia.appendChild(izz);
izz.setTextContent(num2str(Izz, num2strPrecision));

plugin = doc.createElement('plugin');
modelElem.appendChild(plugin);
plugin.setAttribute('filename','libbuoyancy_gazebo_plugin.so');
plugin.setAttribute('name',java.util.UUID.randomUUID.toString());
fluidDensity = doc.createElement('fluid_density');
plugin.appendChild(fluidDensity);
fluidDensity.setTextContent('1000');
fluidLevel = doc.createElement('fluid_level');
plugin.appendChild(fluidLevel);
fluidLevel.setTextContent('0.0');
linearDragElem = doc.createElement('linear_drag');
plugin.appendChild(linearDragElem);
linearDragElem.setTextContent(num2str(linearDrag, num2strPrecision));
angularDragElem = doc.createElement('angular_drag');
plugin.appendChild(angularDragElem);
angularDragElem.setTextContent(num2str(angularDrag, num2strPrecision));

buoyancy = doc.createElement('buoyancy');
plugin.appendChild(buoyancy);
buoyancy.setAttribute('name',java.util.UUID.randomUUID.toString());
linkName = doc.createElement('link_name');
buoyancy.appendChild(linkName);
linkName.setTextContent('link');
massElem = doc.createElement('mass');
buoyancy.appendChild(massElem);
massElem.setTextContent(num2str(mass, num2strPrecision));
buoyancyGeometry = doc.createElement('geometry');
buoyancy.appendChild(buoyancyGeometry);
buoyancyMesh = doc.createElement('mesh');
buoyancyGeometry.appendChild(buoyancyMesh);
buoyancyUriElem = doc.createElement('uri');
buoyancyMesh.appendChild(buoyancyUriElem);
buoyancyUriElem.setTextContent(meshBoatSTLURI);
spawnModel('customboat',xmlwrite(sdfElem), 0, 0, 1, 0, 0, 0, true);

% adjust physics for faster performance
getPhysicsClient = rossvcclient('/gazebo/get_physics_properties');
m = rosmessage(getPhysicsClient);
physicsProperties = call(getPhysicsClient, m);

setPhysicsClient = rossvcclient('/gazebo/set_physics_properties');
m = rosmessage(setPhysicsClient);
m.TimeStep = 0.005;
m.MaxUpdateRate = 200;
m.Gravity = physicsProperties.Gravity;
m.OdeConfig = physicsProperties.OdeConfig;
call(setPhysicsClient, m);

end
