% Each element of the masses vector is the mass of one of the disks (in kg)
masses = transpose([5 1 2 3]);
% by default the tabletop has a mass of 1kg
massOfTableTop = 1;
% each column (note the transpose) of positions represents the 2D-position
% of one of the disks.
% Here, the origin is defined to be the center of the table top.
positions = transpose([1 0;...
                       -1 0.5;...
                       -2 0;...
                       0 2]);
% this function spawns the table system in the simulator
tableSystem(masses, positions, massOfTableTop);