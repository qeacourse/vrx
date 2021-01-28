function [pos,roll] = measureMyBoat()
    modelname = 'customboat';
    [pos, roll] = measureBoatHelper(modelname);
end