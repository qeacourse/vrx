% Each element of the masses vector is the mass of one of the disks
masses = transpose([10 1 2]);
% Each element of the positions vector is the position of one of the disks
% A position of 0 is located at the center of the teeter totter board
positions = [1.5 -1 -1.5];
% by default the board's mass is 0
massOfBoard = 0;
% You can move the pivot of the teeter totter as well
pivotOffset = 0;
% this command spawns the teeter totter in the simulator
teeterTotter(masses, positions, massOfBoard, pivotOffset);