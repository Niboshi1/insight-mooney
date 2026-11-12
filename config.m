function cfg = config()
    % CONFIG  Shared configuration for the insight-mooney experiment.
    %
    % Task-specific settings live in configs/phase1_config.m and
    % configs/phase2_config.m (chained in run.m).

    %% Global
    cfg.skipsynctest = 0;   % 1 = skip PTB sync tests (debug only)
    cfg.eyelinkAudio = 0;   % 1 = EyeLink calibration beeps on

    %% Paths
    cfg.stimDir    = 'assets/stimulus_set/mooney'; % Mooney image root, relative to current directory
    cfg.resultsDir = 'results';                       % results root, relative to current directory

    %% Audio
    cfg.audioChannel      = 0;    % audio input channel for vocal response recording (set in run.m)
    cfg.maxAnswerDuration = 120;  % s, maximum vocal answer recording

    %% Colours (8-bit; grey level or [R G B])
    cfg.itiGray   = 48;  % background grey
    cfg.textColor = 120;   % on-screen text colour

    %% Display geometry / central marker (draw_marker)
    % SET pxPerDeg to the display's pixels per degree of visual angle
    % (= viewDist * tan(1 deg) * wwidth / screenWidth, same units).
    cfg.pxPerDeg    = 40;
    cfg.markerArmDeg = 0.3;   % balanced marker half-arm length
    cfg.markerLineW  = 3;     % px
    cfg.markerColor  = 120;   % 8-bit colour of both cross arms: grey level (scalar) or [R G B]
    cfg.markerDotDeg = 0.15;  % diameter of the red centre dot (attention check)

    %% Images
    cfg.targetWidth = 1024;   % px, width of Mooney images after resizing

    %% Keys
    cfg.triggerkey = 't';
    cfg.answerkey  = '1';

    %% Runtime fields — populated in run.m
    cfg.edfFile      = '';
    cfg.taskMode     = '';   % 'phase1' | 'phase2'
    cfg.subj         = '';
    cfg.runNum       = '';
    cfg.subsetId     = '';
    cfg.tutorial     = false;
    cfg.logDir       = '';
    cfg.initHand     = 'NA';
    cfg.handNow      = 'right';
    cfg.wwidth       = [];
    cfg.hheight      = [];
    cfg.screenNumber = [];
    cfg.ifi          = [];   % inter-frame interval (s), measured at PTB init
end
