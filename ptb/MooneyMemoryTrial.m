function [fixPresentationTime, stimulusPresentationTime, stimEDFTime, responseTime, keyResponse] = MooneyMemoryTrial( ...
    trialno, n_trials, window, imageTexture, blockStartTime, cfg, dummymode, tfun, sfun)

    Eyelink('Message', 'TRIALID %d', trialno);
    Eyelink('Command', 'record_status_message "TRIAL %d/%d"', trialno, n_trials);

    Eyelink('SetOfflineMode');
    Eyelink('Command', 'clear_screen 0');

    if dummymode == 0
        Eyelink('SetOfflineMode');
        Eyelink('StartRecording');
    end

    % Fixation show + in center
    DrawFormattedText(window, '+', 'center', 'center', .2);
    Screen('Flip', window);
    Eyelink('Message', 'CROSS_ONSET'); % log fixation onset to eyelink
    tfun(); % send TTL for fixation onset
    fixPresentationTime = GetSecs - blockStartTime;

    % Wait for 3 seconds + jitter
    WaitSecs(3 + randn); % mean 3s sd 1s

    % Mooney image on screen
    Screen('DrawTexture', window, imageTexture);
    [~, imageStart] = Screen('Flip', window);
    Eyelink('Message', 'IMAGE_ONSET'); % log stimulus onset to eyelink
    tfun(); % send TTL for stimulus onset
    
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
                if isempty(cfg.answerkey) || isequal(temp(1), cfg.answerkey)
                    Eyelink('Message', 'KEY_PRESS'); % log key press to eyelink
                    sfun(); % send TTL for response
                    responseTime = secs - blockStartTime;
                    keyResponse = true;
                    KbReleaseWait(-3);
                end
            end
        end
    end
    
    Eyelink('Message', 'END_STIMULUS'); % log stimulus offset to eyelink
    tfun(); % send TTL for stimulus offset

    % Stop recording and wait
    WaitSecs(0.1);
    Eyelink('StopRecording');
    WaitSecs(0.1);

end