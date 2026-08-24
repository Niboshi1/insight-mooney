function img = load_png(img_path)
    % Read a PNG and return a uint8 RGBA array for Screen('MakeTexture').
    % If the file has no alpha channel, img is MxNx3 (RGB).
    [rgb, ~, alpha] = imread(img_path);

    if isempty(alpha)
        img = rgb;                  % no alpha — return RGB as-is
    else
        img = cat(3, rgb, alpha);  % append alpha as 4th channel → MxNx4
    end
end
