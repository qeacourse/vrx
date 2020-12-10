function comGame()

svc = rossvcclient('/gazebo/pause_physics');
msg = rosmessage(svc);
call(svc, msg);
materials = {'Gazebo/Red','Gazebo/Purple','Gazebo/Green','Gazebo/Orange','Gazebo/Blue'};
for i = 1 : 5
    doc = com.mathworks.xml.XMLUtils.createDocument('robot');
    robotElem = doc.getDocumentElement();
    robotElem.setAttribute('name',['base',num2str(i)]);

    redBox(doc, 'balance', 100, 0.1, 0.1, 1);
    spawnModel(['balance',num2str(i)],xmlwrite(robotElem),2.5*(i-1)-5,0,0);
      
    doc = com.mathworks.xml.XMLUtils.createDocument('sdf');
    sdfElem = doc.getDocumentElement();
    sdfElem.setAttribute('version','1.5');
    modelElem = doc.createElement('model');
    sdfElem.appendChild(modelElem);
    modelElem.setAttribute('name',['poly',num2str(i)]);

    xs = linspace(-1, 1, 151);
    ys = abs(xs).^i;
    points = [xs' ys'; xs(1) ys(1)];
    Zs = [0 0.05];
    stlFileName = makeLoftedMesh(points(:,1), points(:,2), NaN, Zs, [0 0], false);
    meshSTLURI = stageMesh(stlFileName)
    polyline(doc, modelElem, 'poly', 1, Zs(2)-Zs(1), points, materials{i}, false, Zs, meshSTLURI);
    spawnModel(['poly',num2str(i)],xmlwrite(sdfElem),2.5*(i-1)-5,0,1,0,0,0,true);
end

end
