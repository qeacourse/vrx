function tableSystem(masses, positions, massOfBoard)
% simulation of the table top.  'masses' contains the massses of each disk
% on the table top in kg.  The rows of 'positions' give the 2d location of
% the disks on the table top (the 0,0 position is at the center of the
% table top

pivotJointType = 'fixed';
pivotOffset = 0;
if nargin < 3
    massOfBoard = 0;
end
teeterTotter(masses, positions, massOfBoard, pivotOffset, pivotJointType);
end