function [pos,roll] = measureBoatHelper(modelname)
    global getLinkStateSvc;
    if class(getLinkStateSvc) ~= "ros.ServiceClient" || ~isvalid(getLinkStateSvc)
        getLinkStateSvc = rossvcclient('gazebo/get_link_state');
    end
    msg = rosmessage(getLinkStateSvc);
    msg.LinkName = string(modelname) + "::link";
    currState = call(getLinkStateSvc, msg);
    linkState = currState.LinkState;
    pos = [linkState.Pose.Position.X;
           linkState.Pose.Position.Y;
           linkState.Pose.Position.Z];
    quat = readQuaternion(linkState.Pose.Orientation);
    angles = eulerd(quat,'YXZ','point');
    roll = angles(1);
end