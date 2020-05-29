% sorry for lack of comments.
makePolyBoat = true;
doSimplify = true;
% unfortunately, Matlab's patch simplification doesn't always work
% properly for some shapes (it results in some face normals pointing the
% wrong way)
nFaces = 1000; % how many faces do we want to end up with when we do simplification
gridSize = 101;

if makePolyBoat
    L = 0.6;      % boat length
    W = 1;      % deck width
    D = 0.5;    % deck height
    n = 1;      % shape parameter
    [X,Y] = meshgrid(linspace(-W/2,W/2,gridSize),linspace(-L/2,L/2,gridSize));

    stl_file = ['shape_',num2str(n),'_boat.stl'];
    Zhull = D*abs(2*X/W).^n;
    Zdeck = D*ones(size(X));

    Xall = [X(:); X(:)];
    Yall = [Y(:); Y(:)];
    Zall = [Zhull(:); Zdeck(:)];

    [X,Y,Z] = meshgrid(linspace(-W/2,W/2,gridSize),linspace(-L/2,L/2,2),linspace(0,D,gridSize));
    Zhull = D*abs(2*X/W).^n;

    % remap the Z values so they lie on the side of the boat rather than
    % below the hull
    Z = Zhull + Z/D.*(D-Zhull);

    Xall = [Xall(:); X(:)];
    Yall = [Yall(:); Y(:)];
    Zall = [Zall(:); Z(:)];
else
    % make Gaussian Boat
    nFaces = 1000;
    W = 3;
    L = 3;
    [X,Y] = meshgrid(linspace(-W/2,W/2,gridSize),linspace(-L/2,L/2,gridSize));
    Zhull = exp(-X.^2-Y.^2);
    % note: boat might be natural in the other orientation (flip z-axiss)
    Zdeck = zeros(size(X));
    
    Xall = [X(:); X(:)];
    Yall = [Y(:); Y(:)];
    Zall = [Zhull(:); Zdeck(:)];
    stl_file = ['Gaussian_boat.stl'];
end
%note: sides and deck are not explicitly filled in
%they will be covered when we do triangulation

figure;
% alphaShape might be needed for non-convex (need to fill all sides in that
% case
shp = alphaShape(Xall,Yall,Zall);
% usually the default value of alpha is a bit too small, but not always.
% this might need to be adjusted on a boat, by boat basis
shp.Alpha = shp.Alpha*1.1;
p = plot(shp);
daspect([1 1 1])
view(3);
axis tight;
% built-in patch simplification!  This seems to not be quite as good as the
% one in meshlab (sometimes the faces seem to face inward rather than
% outward, and it doesn't work on n <= 1 for the polyboat)
if doSimplify
    reducepatch(p, nFaces, 'fast');
    % sometimes reducepatch gives triangles with 0 area.  Find these bad
    % triangles and get rid of them (they cause issues in some of the tools
    % we use
    shouldKeep = zeros(size(p.Faces,1),1);
    for i = 1 : size(p.Faces,1)
        v1 = p.Vertices(p.Faces(i,1),:);
        v2 = p.Vertices(p.Faces(i,2),:);
        v3 = p.Vertices(p.Faces(i,3),:);

        shouldKeep(i) = norm(cross(v2-v1,v3-v1)) > 0;
    end

    p.Faces = p.Faces(shouldKeep==1,:);
end
p.FaceColor = 'red';
p.BackFaceLighting = 'unlit';
p.EdgeColor = 'none';
hold on;
scatter3(Xall,Yall,Zall,'b.');

stl_file
stlwrite(triangulation(p.Faces,p.Vertices),stl_file)
