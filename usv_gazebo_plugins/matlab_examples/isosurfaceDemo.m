% sorry for lack of comments.
boat_length = 1;
[X,Y,Z] = meshgrid(linspace(-1.2,1.2,200),linspace(-boat_length,boat_length,200),linspace(-1.2,1.2,200));
deckHeight = 0.5;
W = 1;
n = 4;
nFaces = 200; % how many faces do we want to end up with when we do simplification
stl_file = ['shape_',num2str(n),'_boat.stl'];
Data = double((Z >= deckHeight*abs(2*X/W).^n & Z <= deckHeight & boat_length/2 >= abs(Y)));
figure;
% JOHN: note the 1-Data here.  I think that MATLAB orients the normal
% vectors of the polyhedron faces to point towards larger values in Data.
% Therefore, you want to make sure to use 1-Data so the vectors point out
% of the solid.  I'm only ~90% confident that this is correct though!
p = patch(isosurface(X,Y,Z,1-Data,0.5));
isonormals(X,Y,Z,Data,p);
p.FaceColor = 'red';
p.EdgeColor = 'none';
daspect([1 1 1])
view(3);
axis tight;
% built-in patch simplification!
reducepatch(p, nFaces);
stlwrite(triangulation(p.Faces,p.Vertices),stl_file)