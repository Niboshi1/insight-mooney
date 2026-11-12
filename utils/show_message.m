function show_message(window, cfg, msg)
    % SHOW_MESSAGE  Show a centred text screen on the ITI gray and wait for
    % any key (instruction / break screens).
    %
    %   show_message(window, cfg, msg)

    Screen('FillRect', window, cfg.itiGray / 255);
    DrawFormattedText(window, msg, 'center', 'center', cfg.textColor / 255);
    Screen('Flip', window);
    KbWait(-3, 2);
    KbReleaseWait(-3);
end
