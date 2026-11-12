function el = eyelinkCalibrate(window, cfg, dummymode)
    %% Calibrate
    el = EyelinkInitDefaults(window);

    el.calibrationtargetsize  = 3;
    el.calibrationtargetwidth = 0.7;
    el.backgroundcolour       = repmat(cfg.itiGray/255, 1, 3);
    el.calibrationtargetcolour= [0 0 0];
    el.msgfontcolour          = [0 0 0];

    % Set calibration beeps (0 = sound off, 1 = sound on)
    el.targetbeep = cfg.eyelinkAudio;  % sound a beep when a target is presented
    el.feedbackbeep = cfg.eyelinkAudio;  % sound a beep after calibration or drift check/correction

    EyelinkUpdateDefaults(el);

    Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, cfg.wwidth-1, cfg.hheight-1);
    Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, cfg.wwidth-1, cfg.hheight-1);

    Eyelink('Command', 'calibration_type = HV9');
    Eyelink('Command', 'button_function 5 "accept_target_fixation"');

    HideCursor(cfg.screenNumber);
    ListenChar(-1);

    if dummymode == 0
        Eyelink('Command', 'clear_screen 0');
        EyelinkDoTrackerSetup(el);
    end

end