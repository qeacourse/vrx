function stl_file = makeLoftedMesh(x, y, deckHeight, Zs, loftCurve, visualize, finalVertexTransformation, stlCopyPath)
if nargin < 6
    visualize = true;
end
% hack to make sure we have a unique mesh everytime
stl_file = [char(java.util.UUID.randomUUID.toString()),'.stl'];
points = [x(1:end-1) y(1:end-1)];
npoints = size(points,1);

verts = zeros(0,3);
faces = zeros(0,3);

for i=1:length(Zs)
    % don't need to repeat the last point
    slicePoints = points;
    slicePoints(:,end) = slicePoints(:,end)+loftCurve(i);
    slicePoints(:,end+1) = Zs(i);
    verts = [verts; slicePoints];
    if i >= 2
        % TODO: if needed, get rid of loop to make faster
        % connect this slice to the previous one
        for j=1:npoints
            nextCCWPoint = mod(j,npoints)+1;
            faces(end+1,:) = [j+(i-1)*npoints, j+(i-2)*npoints, nextCCWPoint+(i-1)*npoints];
            faces(end+1,:) = [nextCCWPoint+(i-2)*npoints nextCCWPoint+(i-1)*npoints j+(i-2)*npoints];
        end
    end
end

% add the end caps
for i = [1 length(Zs)]
    slicePoints = points;
    slicePoints(:,end) = slicePoints(:,end)+loftCurve(i);
    slicePoints(:,end+1) = Zs(i);
    T = triangulation(polyshape(slicePoints(:,1),slicePoints(:,2)));

    vertOffset = size(verts,1);
    verts = [verts; T.Points Zs(i)*ones(size(T.Points,1),1)];
    % make sure normal vectors point in the correct direction
    NewConnectivityList = T.ConnectivityList;
    for j=1:size(T.ConnectivityList,1)
        vec1 = T.Points(T.ConnectivityList(j,2),:) - T.Points(T.ConnectivityList(j,1),:);
        vec2 = T.Points(T.ConnectivityList(j,3),:) - T.Points(T.ConnectivityList(j,1),:);
        cp = cross([vec1 0], [vec2 0]);
        assert(cp(3) ~= 0);
        if (i == 1 && cp(3) > 0) || (i == length(Zs) && cp(3) < 0)
            % flip normal vector
            NewConnectivityList(j,:) = [T.ConnectivityList(j,1) T.ConnectivityList(j,3) T.ConnectivityList(j,2)];
        end
    end
    faces = [faces; NewConnectivityList+vertOffset];
end

if ~isnan(deckHeight)
    % slice off the deck
    planes.n = [0 1 0];
    planes.r = [0 deckHeight 0];
    polygons = mesh_xsections( verts, faces, planes, []);
    for i=1:size(polygons{1},1)
        p = polyshape(polygons{1}{i}(:,[1 3]));
        T = triangulation(p);

        vertOffset = size(verts,1);
        verts = [verts; T.Points(:,1) deckHeight*ones(size(T.Points,1),1) T.Points(:,2)];
        % make sure normal vectors point in the correct direction
        NewConnectivityList = T.ConnectivityList;
        for j=1:size(T.ConnectivityList,1)
            vec1 = T.Points(T.ConnectivityList(j,2),:) - T.Points(T.ConnectivityList(j,1),:);
            vec2 = T.Points(T.ConnectivityList(j,3),:) - T.Points(T.ConnectivityList(j,1),:);
            cp = cross([vec1(1) 0 vec1(2)], [vec2(1) 0 vec2(2)]);
            assert(cp(2) ~= 0);
            if cp(2) < 0
                % flip normal vector
                NewConnectivityList(j,:) = [T.ConnectivityList(j,1) T.ConnectivityList(j,3) T.ConnectivityList(j,2)];
            end
        end
        faces = [faces; NewConnectivityList+vertOffset];
    end

    % cut off the mesh above the deck
    newFaces = zeros(0,3)
    for i=1:size(faces,1)
        V = verts(faces(i,:),:);
        vec1 = V(2,:) - V(1,:);
        vec2 = V(3,:) - V(1,:);
        cp = cross(vec1, vec2);
        % keep as is
        above = V(V(:,2) > deckHeight, :);
        below = V(V(:,2) <= deckHeight, :);
        if size(below,1) == 3
            newFaces(end+1,:) = faces(i,:);
        elseif size(below,1) == 1
            % need to split into a single below deck triangle
            scale = 1./((above(:,2)-below(2))/(deckHeight-below(2)));
            % Note scale is undefined if triangle just touches the plane
            clippedToPlane = (above-below).*repmat(scale,[1 3])+below;
            newPoints = [below; clippedToPlane];
            newPointsIds = [1 2 3]+size(verts,1);
            verts = [verts; newPoints];
            vec1new = newPoints(2,:) - newPoints(1,:);
            vec2new = newPoints(3,:) - newPoints(1,:);
            cpnew = cross(vec1new, vec2new);
            if sign(dot(cpnew,cp)/(norm(cpnew)*norm(cp))) == -1
                newFaces(end+1,:) = [newPointsIds(1) newPointsIds(3) newPointsIds(2)];
            else
                newFaces(end+1,:) = [newPointsIds(1) newPointsIds(2) newPointsIds(3)];
            end
        elseif size(below,1) == 2
            scale = 1./((above(2)-below(:,2))./(deckHeight-below(:,2)));
            newPoints = below;
            newPoints = [newPoints; (above-below).*repmat(scale,[1 3])+below];
            newPointsIds = [1 2 3 4]+size(verts,1);
            verts = [verts; newPoints];

            vec1new = newPoints(3,:) - newPoints(1,:);
            vec2new = newPoints(2,:) - newPoints(1,:);
            cpnew = cross(vec1new, vec2new);
            if sign(dot(cpnew,cp)/(norm(cpnew)*norm(cp))) == -1
                newFaces(end+1,:) = [newPointsIds(1) newPointsIds(2) newPointsIds(3)];
            else
                newFaces(end+1,:) = [newPointsIds(1) newPointsIds(3) newPointsIds(2)];
            end
            vec1new = newPoints(4,:) - newPoints(3,:);
            vec2new = newPoints(2,:) - newPoints(3,:);
            if sign(dot(cpnew,cp)/(norm(cpnew)*norm(cp))) == 1
                newFaces(end+1,:) = [newPointsIds(3) newPointsIds(4) newPointsIds(2)];
            else
                newFaces(end+1,:) = [newPointsIds(3) newPointsIds(2) newPointsIds(4)];
            end
        end
    end
    faces = newFaces;
end
% remove 0 area faces
areas = zeros(size(faces,1),1);
for i=1:size(faces,1)
    V = verts(faces(i,:),:);
    vec1 = V(2,:) - V(1,:);
    vec2 = V(3,:) - V(1,:);
    cp = cross(vec1, vec2);
    areas(i) = norm(cp)/2;
end
faces = faces(areas>0,:);

% get rid of dangling vertices
u = unique(faces(:));
mappings = zeros(size(verts,1),1);
mappings(u) = [1:length(u)];
faces = mappings(faces);
verts = verts(u,:);

% get rid of non-unique vertices
[verts,~,mappings] = unique(verts,'rows');
faces = mappings(faces);

if nargin >= 7
    vertsHomogeneous = [verts ones(size(verts,1),1)]';
    vertsTransformed = finalVertexTransformation*vertsHomogeneous;
    verts = vertsTransformed(1:3,:)';
end

if visualize
    figure;
    view(3);
    axis equal;
    p = patch('Faces',faces,'Vertices',verts);
    p.EdgeColor = [1 0 0];
    xlabel('x (mm)');
    ylabel('y (mm)');
    zlabel('z (mm)');
end
disp(['Num vertices ', num2str(size(verts,1))]);
disp(['Num faces ', num2str(size(faces,1))]);

TR = triangulation(faces, verts);
[filepath,name,ext] = fileparts(stl_file);
modelDir = fullfile(tempdir, name);
mkdir(modelDir);
meshDir = fullfile(modelDir,'meshes');
mkdir(meshDir);
stlwrite(TR, fullfile(meshDir, stl_file));
if nargin >= 8
    stlwrite(TR, stlCopyPath);
    stl_file = stlCopyPath;
end
end
