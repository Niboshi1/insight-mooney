function [promptTime, suddennessRating, suddennessTime, confidenceRating, confidenceTime, quitNow] = phase1_response(trial, window, pahandle, cfg, keyResponse, blockStartTime, tfun, sfun)
    quitNow = false;
    suddennessRating = NaN;  suddennessTime = NaN;
    confidenceRating = NaN;  confidenceTime = NaN;

    %% Fixation between image and prompt
    % Fixation show + in center
    draw_cross(window, cfg);
    tfun('CROSS_ONSET_POST_IMG'); % send TTL for fixation onset
    WaitSecs(3 + randn); % mean 3s sd 1s

    %% Case 1: If the participant was able to solve the Mooney image (keyResponse = true)
    if keyResponse

        % -- Vocal response --
        resptext = 'Please answer what you saw';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);
        tfun('TEXT_PROMPT_QANSWER'); % send TTL for response prompt
        promptTime = GetSecs - blockStartTime;

        % Start audio recording (if device is available)
        if ~isempty(pahandle)
            PsychPortAudio('GetAudioData', pahandle, cfg.maxAnswerDuration);
            PsychPortAudio('Start', pahandle, 0, 0, 1);
        end
        audioStartTime = GetSecs;

        % Wait until triggerkey is pressed
        while true
            [~, keyCode] = KbWait(-3, 2);
            temp = KbName(keyCode);
            if ~isempty(temp) && isequal(temp(1), cfg.triggerkey)
                KbReleaseWait(-3);
                break;
            end
        end
        audioElapsed = GetSecs - audioStartTime;

        % Stop audio recording and save actual elapsed audio (if device is available)
        if ~isempty(pahandle)
            PsychPortAudio('Stop', pahandle, 0);  % 0 = stop immediately, don't wait for drain
            [recordedAudio, ~] = PsychPortAudio('GetAudioData', pahandle);
            % Trim to actual recorded duration (samples = elapsed * sampleRate)
            nSamples = min(size(recordedAudio, 2), round(audioElapsed * 44100));
            recordedAudio = recordedAudio(:, 1:nSamples);
            filename = fullfile(cfg.logDir, sprintf('%03d_recognition.wav', trial));
            audiowrite(filename, recordedAudio', 44100);
        end

        % Fixation interval
        draw_cross(window, cfg);
        WaitSecs(1 + randn);

        % --- Suddenness rating (1 = sudden / popped out, 5 = gradual / figured it out) ---
        KbReleaseWait(-3);
        ratetext = ['In a scale of 1-5, how did the solution come to you?\n\n' ...
                    '\n\n' ...
                    'sudden (popped out) <-   1   2   3   4   5   -> gradual (figured it out)'];
        DrawFormattedText(window, ratetext, 'center', 'center', .2);
        Screen('Flip', window);
        tfun('TEXT_PROMPT_SUDDENNESS');

        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && any(temp(1) == '12345')
                    suddennessRating = str2double(temp(1));
                    suddennessTime   = GetSecs - blockStartTime;
                    sfun(sprintf('KEY_PRESS_SUDDENNESS_%d', suddennessRating));
                    KbReleaseWait(-3);
                    WaitSecs(0.3);  % brief pause
                    break;
                elseif ~isempty(temp) && isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end

        % Fixation interval
        draw_cross(window, cfg);
        WaitSecs(1 + randn);

        % --- Confidence rating (1 = not confident, 5 = very confident) ---
        KbReleaseWait(-3);
        ratetext = ['In a scale of 1-5, how confident are you in your answer?\n\n' ...
                    '\n\n' ...
                    'Not confident <-   1   2   3   4   5   -> Very confident'];
        DrawFormattedText(window, ratetext, 'center', 'center', .2);
        Screen('Flip', window);
        tfun('TEXT_PROMPT_CONFIDENCE');

        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && any(temp(1) == '12345')
                    confidenceRating = str2double(temp(1));
                    confidenceTime   = GetSecs - blockStartTime;
                    sfun(sprintf('KEY_PRESS_CONFIDENCE_%d', confidenceRating));
                    KbReleaseWait(-3);
                    WaitSecs(0.3);  % brief pause
                    break;
                elseif ~isempty(temp) && isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end

    %% Case 2: If the participant was not able to solve the Mooney image (keyResponse = false)
    else % if not able to solve
        % Prompt for key press TODO: decide on response key
        resptext = 'Please press "1" key to proceed';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);
        tfun('TEXT_PROMPT_QKEYPRESS'); % send TTL for response prompt
        promptTime = GetSecs - blockStartTime;

        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && isequal(temp(1), cfg.answerkey)
                    sfun('KEY_PRESS_NOINSIGHT'); % send TTL for response
                    return;
                elseif ~isempty(temp) && isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end
    end
end