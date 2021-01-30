% p is the boat shape parameter
p = 2;  % let's make a paraboboat

% we are going to chop the mesh off at this height (z = deckHeight)
deckHeight = 0.0508;     % meters (corresponds to a 2-inch high boat)

% We must construct the vertices of the cross-section of the boat.  They
% should be specified in counter clockwise order starting from the vertex
% at the bottom of the mesh.  The last vertex should be repeated.
% The linspace for x below ensures that we do this.

deckWidth = 0.0762;       % meters (corresponds to a 3-inch wide boat)
x = linspace(0,deckWidth/2, 15)';  % meters
x = [x; linspace(-deckWidth/2,0,15)'];  % meters
% this is the curve that defines the bottom of the boat hull
z = deckHeight*abs(2*x/deckWidth).^p;

% these are the y-values (y runs longitudinally down the boat) we want to
% create our mesh at.
y = linspace(-0.106,0.106,25);  % meters (corresponds to an 8-inch long boat)
% the loftCurve tells us how much to raise (in the z-direction the cross
% section (defined using the vertices in x and z) up.
loftCurve = (2*y).^2;

% the function below uses a different definition of the coordinate axes by
% default, so we pass this matrix in to swap the axes back to what we want
% and make the mesh in units of millimeters (better for 3d-printing)
swapYandZAxesInMesh = 1000*[1 0 0 0;...
                            0 0 -1 0;...
                            0 1 0 0;...
                            0 0 0 1];

makeLoftedMesh(x, z, deckHeight, y, loftCurve, true, swapYandZAxesInMesh, 'myparaboboat.stl')
