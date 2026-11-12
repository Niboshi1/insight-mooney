function cfg = phase1_config(cfg)
    % PHASE1_CONFIG  Recognition task (insight) settings.

    cfg.phase1.imageDuration = 10;  % s, maximum duration the image is shown
    cfg.phase1.blankDuration = 1;   % s, interval between image offset and response

    %% Tutorial (all steps advance with cfg.triggerkey; 'q' aborts)
    cfg.phase1.tutorialTrials     = 4;        % number of sample trials
    cfg.phase1.tutorialScale      = 0.8;      % sample image size relative to the real trial (room for text)
    cfg.phase1.tutorialSwitchEvery = 2;       % hand instruction repeats every N sample trials
    cfg.phase1.tutorialImgDir     = 'assets'; % folder with the example images below
    cfg.phase1.tutorialImgCol     = 'tutorial_col.png';
    cfg.phase1.tutorialImgGray    = 'tutorial_gray.png';
    cfg.phase1.tutorialImgBin     = 'tutorial_bin.png';
end
