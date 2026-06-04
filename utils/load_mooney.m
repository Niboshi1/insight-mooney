function imageTextures = load_mooney(window, cfg)

    stimDir = cfg.stimDir;
    targetWidth = cfg.targetWidth;
    taskMode = cfg.taskMode; 
    subsetId = cfg.subsetId;

    if taskMode == 1
        taskDir = 'recognition';
    else
        taskDir = 'memory';
    end

    % print info about loading
    stimPath = fullfile(stimDir, subsetId, taskDir);
    disp(['Loading images from: ' stimPath]);   

    files = dir(fullfile(stimPath, '*.jpg'));
    filenames = {files.name};

    numImages = length(filenames);
    imageTextures = cell(1, numImages);

    for i = 1:numImages
        img = imread(fullfile(stimPath, filenames{i}));
        img = imresize(img, targetWidth/size(img,2));
        imageTextures{i} = Screen('MakeTexture', window, img);
    end

    % Shuffle images
    rng(42);
    imageTextures = imageTextures(randperm(numImages));

    % Report completion and return textures
    disp('Finished loading images.');
    disp(numImages);
end