function img = load_png(img_path)
    % Load hand switch image
    [img, ~, alpha] = imread(img_path);
    alpha = alpha*255;

    % Invert grayscale and prepare RGBA
    img = 255 - img;                   % invert grayscale
    img = repmat(img, [1 1 3]);       % replicate to RGB
    img(:, :, 4) = alpha;             % append alpha channel
end