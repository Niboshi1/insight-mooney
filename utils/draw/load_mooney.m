function imageTextures = load_mooney(window, cfg) 
    if strcmp(cfg.taskMode, 'phase1')
        taskDir = 'recognition';
    else
        taskDir = 'memory';
    end

    % print info about loading
    stimPath = fullfile(cfg.stimDir, cfg.subsetId, taskDir);
    fprintf('Loading images from: %s\n', stimPath);

    files = dir(fullfile(stimPath, '*.png'));
    filenames = {files.name};

    numImages = length(filenames);
    imageTextures = cell(1, numImages);

    for i = 1:numImages
        img = imread(fullfile(stimPath, filenames{i}));
        img = imresize(img, cfg.targetWidth/size(img,2));
        imageTextures{i} = Screen('MakeTexture', window, img);
    end

    % Shuffle images
    rng(42);
    imageTextures = imageTextures(randperm(numImages));

    % Report completion and return textures
    fprintf('Finished loading images.');
    fprintf('Total images loaded: %d\n', numImages);
end