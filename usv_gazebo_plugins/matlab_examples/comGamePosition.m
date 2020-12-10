function comGamePosition(sheetId, x, y)
    % the sheetId must be 1, 2, 3, 4, or 5
    assert(sheetId == 1 || sheetId == 2 || sheetId == 3 || sheetId == 4 || sheetId == 5);

    global setStateSvc;
    if class(setStateSvc) ~= "ros.ServiceClient" || ~isvalid(setStateSvc)
        setStateSvc = rossvcclient('gazebo/set_model_state');
    end
    
    originX = 2.5*(sheetId - 2)-2.5;
    originY = 0;
    
    msg = rosmessage(setStateSvc);
    msg.ModelState.Pose.Position.X = originX + x;
    msg.ModelState.Pose.Position.Y = originY + y;
    msg.ModelState.Pose.Position.Z = 1.0;    % the post is 1.0m tall
    msg.ModelState.ModelName = "poly"+sheetId;

    call(setStateSvc, msg);
end