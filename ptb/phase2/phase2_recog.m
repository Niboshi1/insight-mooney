function [fixPresentationTime, stimulusPresentationTime, stimEDFTime, responseTime, keyResponse] = phase2_recog( ...
    trialno, n_trials, window, imageTexture, blockStartTime, cfg, tfun, sfun)

    Eyelink('Message', 'TRIALID %d', trialno);
    Eyelink('Command', 'record_status_message "TRIAL %d/%d"', trialno, n_trials);
    Eyelink('Command', 'clear_screen 0');

    % Fixation show + in center
    draw_cross(window, cfg);
    tfun('CROSS_ONSET_PRE_IMG'); % send TTL for fixation onset
    fixPresentationTime = GetSecs - blockStartTime;

    % Wait for 3 seconds + jitter
    WaitSecs(3 + randn); % mean 3s sd 1s

    % Mooney image on screen
    Screen('DrawTexture', window, imageTexture);
    [~, imageStart] = Screen('Flip', window);
    tfun('IMAGE_ONSET'); % send TTL for stimulus onset

    stimEDFTime = (Eyelink('TrackerTime')) * 1000;
    stimulusPresentationTime = imageStart - blockStartTime;

    % Display image for 10 seconds
    startTime = GetSecs;
    responseTime = Inf;
    keyResponse = false;

    while (GetSecs - startTime) < cfg.imageMemoryDuration
        if ~keyResponse
            [keyIsDown, secs, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && isequal(temp(1), cfg.answerkey)
                    sfun('KEY_PRESS_MEMORY'); % send TTL for response
                    responseTime = secs - blockStartTime;
                    keyResponse = true;
                end
            end
        end
    end
    
    tfun('END_STIMULUS'); % send TTL for stimulus offset

end