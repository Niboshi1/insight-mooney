function cfg = config()
    %CONFIG_FIXSTIM Central place for experiment constants.

    % ---- asset images path ----
    cfg.stimDir = 'assets/stimulus_set/soft_norm'; % directory of Mooney images relative to current directory

    % ---- Results path ----
    cfg.resultsDir = 'results'; % directory to save results relative to current directory

    % ---- Audio input channel ----
    cfg.audioChannel = 13; % audio input channel for vocal response recording

    % ---- Timing ----
    cfg.imageDuration    = 2; % maximum duration the image is shown
    cfg.blankDuration    = 1; % interval between Mooney image presentation and response
    cfg.answerDuration   = 5; % duration for vocal answering
    cfg.maxAnswerDuration = 120;

    % ---- Timing 2 ----
    cfg.imageMemoryDuration = 8;

    % ---- Stim presentation ----
    cfg.targetWidth      = 1024;

    % filled in at runtime:
    cfg.initHand = 'NA';
    cfg.handNow = 'right';
    cfg.wwidth = [];
    cfg.hheight = [];
    cfg.screenNumber = [];
    cfg.triggerkey = 't';
    cfg.answerkey = '1';

end