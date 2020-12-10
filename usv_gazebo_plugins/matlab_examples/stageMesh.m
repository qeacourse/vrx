function meshBoatSTLURI = stageMesh(stlFileName)
    global qeaSimStarted;

    [~, modelName, ~] = fileparts(stlFileName);
    meshBoatSTLURI = ['model://',modelName,'/meshes/',stlFileName];
    if ismac
        docker_bin = '/usr/local/bin/docker';
    elseif ispc || isunix
        docker_bin = 'docker';
    end
    if ismac || ispc || size(qeaSimStarted,1)
        % we are running through docker.  Eventually we will use
        % docker cp to sync the files to models directory and the
        % gzweb directory
        modelFolderPath = fullfile(tempdir, modelName);
        system([docker_bin,' cp ',modelFolderPath,' neato:/root/.gazebo/models']);
        system([docker_bin,' cp ',modelFolderPath,' neato:/root/gzweb/http/client/assets']);
    else
        % this is when we are running outside of Docker
        mkdir(fullfile('~','.gazebo'));
        mkdir(fullfile('~','.gazebo','models'));
        copyfile(fullfile(tempdir, modelName),fullfile('~','.gazebo','models',modelName));
    end
end
