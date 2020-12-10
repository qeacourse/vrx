function placeBoat(n, pitchAngle, verticalDisplacement)
    modelname = getBoatModelName(n);

    global setStateSvc;
    if class(setStateSvc) ~= "ros.ServiceClient" || ~isvalid(setStateSvc)
        setStateSvc = rossvcclient('gazebo/set_model_state');
    end
    [currPos, ~] = measureBoat(n);

    msg = rosmessage(setStateSvc);
    D = 0.5;
    msg.ModelState.ModelName = modelname;
    quat = eul2quat([0 deg2rad(pitchAngle) 0]);
    msg.ModelState.Pose.Orientation.W = quat(1);
    msg.ModelState.Pose.Orientation.X = quat(2);
    msg.ModelState.Pose.Orientation.Y = quat(3);
    msg.ModelState.Pose.Orientation.Z = quat(4);

    % Boat parameters (see getWaterLine)
    L = 0.6; % m
    W = 1; % m
    D = 0.5; % m
    msg.ModelState.Pose.Position.Z = verticalDisplacement;
    msg.ModelState.Pose.Position.X = currPos(1);
    msg.ModelState.Pose.Position.Y = currPos(2);
    
    ret = call(setStateSvc, msg);
end
