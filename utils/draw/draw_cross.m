function draw_cross(window,cfg)
    % Get the centre coordinate of the window
    xCenter = cfg.wwidth / 2;
    yCenter = cfg.hheight / 2;

    % Here we set the size of the arms of our fixation cross
    fixCrossDimPix = 40;

    % Now we set the coordinates (these are all relative to zero we will let
    % the drawing routine center the cross in the center of our monitor for us)
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];

    % Set the line width for our fixation cross
    lineWidthPix = 8;

    % Draw the fixation cross in white, set it to the center of our screen and
    % set good quality antialiasing
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, .2, [xCenter yCenter], 2);

    % Flip to the screen
    Screen('Flip', window);
end