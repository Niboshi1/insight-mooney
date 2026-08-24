function [fixPresentationTime, stimulusPresentationTime, stimPresentationEDFTime, responseTime, keyResponse] = phase1_recog( ...
    trialno, n_trials, window, imageTexture, blockStartTime, cfg, tfun, sfun)

    Eyelink('Message', 'TRIALID %d', trialno);
    Eyelink('Command', 'record_status_message "TRIAL %d/%d"', trialno, n_trials);
    Eyelink('Command', 'clear_screen 0');

    % Fixation show + in center
    draw_cross(window, cfg);
    Eyelink('Message', 'CROSS_ONSET_PRE_IMG'); % log fixation onset to eyelink
    tfun(); % send TTL for fixation onset
    fixPresentationTime = GetSecs - blockStartTime;

    % Wait for 3 seconds + jitter
    WaitSecs(3 + randn); % mean 3s sd 1s

    % Mooney image on screen
    Screen('DrawTexture', window, imageTexture);
    [~, imageStart] = Screen('Flip', window);
    Eyelink('Message', 'IMAGE_ONSET'); % log stimulus onset to eyelink
    tfun(); % send TTL for stimulus onset

    stimPresentationEDFTime = (Eyelink('TrackerTime')) * 1000;
    stimulusPresentationTime = imageStart - blockStartTime;

    % Display image for 10 seconds
    startTime = GetSecs;
    responseTime = Inf;
    keyResponse = false;

    while (GetSecs - startTime) < cfg.imageDuration
        if ~keyResponse
            [keyIsDown, secs, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if isempty(cfg.answerkey) || isequal(temp(1), cfg.answerkey)
                    Eyelink('Message', 'KEY_PRESS_INSIGHT'); % log key press to eyelink
                    sfun(); % send TTL for response
                    responseTime = secs - blockStartTime;
                    keyResponse = true;
                end
            end
        end
    end
    Eyelink('Message', 'END_STIMULUS'); % log stimulus offset to eyelink
    tfun(); % send TTL for stimulus offset

end