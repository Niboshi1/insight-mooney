function cfg = config()
    %CONFIG_FIXSTIM Central place for experiment constants.

    % ---- Mooney images path ----
    cfg.stimDir = 'stimulus_set'; % directory of Mooney images relative to current directory

    % ---- Results path ----
    cfg.resultsDir = 'results'; % directory to save results relative to current directory

    % ---- Timing ----
    cfg.imageDuration    = 10; % maximum duration the image is shown
    cfg.blankDuration    = 1; % interval between Mooney image presentation and response
    cfg.answerDuration   = 5; % duration for vocal answering

    % ---- Timing 2 ----
    cfg.imageMemoryDuration = 8;


    % ---- Stim presentation ----
    cfg.targetWidth      = 1024;

    % filled in at runtime:
    cfg.wwidth = [];
    cfg.hheight = [];
    cfg.screenNumber = [];
    cfg.triggerkey = 't';
    cfg.answerkey = '1';

end