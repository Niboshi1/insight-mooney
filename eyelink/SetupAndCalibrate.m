function el = SetupAndCalibrate(window, cfg, dummymode)

el = EyelinkInitDefaults(window);

el.calibrationtargetsize  = 3;
el.calibrationtargetwidth = 0.7;
el.backgroundcolour       = [120 120 120];
el.calibrationtargetcolour= [0 0 0];
el.msgfontcolour          = [0 0 0];

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