function imageTextures = load_moony(window, stimDir, targetWidth)
    files = dir(fullfile(stimDir, ['*.' 'jpg']));
    filenames = {files.name};

    numImages = length(filenames);
    imageTextures = cell(1, numImages);

    for i = 1:numImages
        img = imread(fullfile(stimDir, filenames{i}));
        img = imresize(img, targetWidth/size(img,2));
        imageTextures{i} = Screen('MakeTexture', window, img);
    end

    % Report completion and return textures
    disp('Finished loading images.');
end