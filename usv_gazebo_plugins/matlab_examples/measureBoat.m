function [pos,roll] = measureBoat(n)
    modelname = getBoatModelName(n);
    [pos, roll] = measureBoatHelper(modelname);
end