% sorry for lack of comments.
L = 0.6;      % boat length
W = 1;      % deck width
D = 0.5;    % deck height
n = 8;      % shape parameter
[X,Y] = meshgrid(linspace(-W/2,W/2,101),linspace(-L/2,L/2,101));

nFaces = 200; % how many faces do we want to end up with when we do simplification
stl_file = ['shape_',num2str(n),'_boat.stl'];
Zhull = D*abs(2*X/W).^n;

%note: sides and deck are not explicitly filled in
%they will be covered when we do triangulation

figure;
% alphaShape might be needed for non-convex (need to fill all sides in that
% case
F = freeBoundary(delaunayTriangulation(X(:),Y(:),Zhull(:)));
p = trimesh(F,X(:),Y(:),Zhull(:));
p.FaceColor = 'red';
p.EdgeColor = 'none';
daspect([1 1 1])
view(3);
axis tight;
% built-in patch simplification!
reducepatch(p, nFaces);
stlwrite(triangulation(p.Faces,p.Vertices),stl_file)