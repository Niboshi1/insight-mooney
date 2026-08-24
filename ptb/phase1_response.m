function [promptTime, suddennessRating, suddennessTime, confidenceRating, confidenceTime, quitNow] = phase1_response(trial, window, pahandle, cfg, keyResponse, blockStartTime, tfun, sfun)
    quitNow = false;
    suddennessRating = NaN;  suddennessTime = NaN;
    confidenceRating = NaN;  confidenceTime = NaN;

    % Fixation show + in center
    draw_cross(window, cfg);
    Eyelink('Message', 'CROSS_ONSET_POST_IMG'); % log fixation onset to eyelink
    tfun(); % send TTL for fixation onset
    WaitSecs(3 + randn); % mean 3s sd 1s

    if keyResponse % if answered
        % Prompt for vocal response
        resptext = 'Please answer what you saw';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);
        Eyelink('Message', 'TEXT_PROMPT_QANSWER'); % log prompt onset to eyelink
        tfun(); % send TTL for response prompt
        promptTime = GetSecs - blockStartTime;

        % Start audio recording
        PsychPortAudio('GetAudioData', pahandle, cfg.answerDuration+2);
        PsychPortAudio('Start', pahandle, 0, 0, 1);

        while true
            [~, keyCode] = KbWait(-3, 2);
            temp = KbName(keyCode);

            if isempty(cfg.triggerkey) || (~isempty(temp) && isequal(temp(1), cfg.triggerkey))
                break;
            end
        end
        
        % Stop audio recording and save
        PsychPortAudio('Stop', pahandle);
        [recordedAudio, ~] = PsychPortAudio('GetAudioData', pahandle);
        filename = [cfg.logDir, '/', sprintf('%03d', trial), '_recognition.wav'];
        audiowrite(filename, recordedAudio, 44100);

        % --- Suddenness rating (1 = sudden / popped out, 5 = gradual / figured it out) ---
        KbReleaseWait(-3);
        ratetext = ['In a scale of 1-5, how did the solution come to you?\n\n' ...
                    'sudden (popped out) <-   1   2   3   4   5   -> gradual (figured it out)'];
        DrawFormattedText(window, ratetext, 'center', 'center', .2);
        Screen('Flip', window);
        Eyelink('Message', 'TEXT_PROMPT_SUDDENNESS');
        tfun();

        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && any(temp(1) == '12345')
                    suddennessRating = str2double(temp(1));
                    suddennessTime   = GetSecs - blockStartTime;
                    Eyelink('Message', sprintf('KEY_PRESS_SUDDENNESS_%d', suddennessRating));
                    sfun();
                    break;
                elseif ~isempty(temp) && isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end

        % --- Confidence rating (1 = not confident, 5 = very confident) ---
        KbReleaseWait(-3);
        ratetext = ['In a scale of 1-5, how confident are you in your answer?\n\n' ...
                    'Not confident <-   1   2   3   4   5   -> Very confident'];
        DrawFormattedText(window, ratetext, 'center', 'center', .2);
        Screen('Flip', window);
        Eyelink('Message', 'TEXT_PROMPT_CONFIDENCE');
        tfun();

        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && any(temp(1) == '12345')
                    confidenceRating = str2double(temp(1));
                    confidenceTime   = GetSecs - blockStartTime;
                    Eyelink('Message', sprintf('KEY_PRESS_CONFIDENCE_%d', confidenceRating));
                    sfun();
                    break;
                elseif ~isempty(temp) && isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end

    else % if not able to solve
        % Prompt for key press TODO: decide on response key
        resptext = 'Please press "1" key to proceed';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);
        Eyelink('Message', 'TEXT_PROMPT_QKEYPRESS'); % log prompt onset to eyelink
        tfun(); % send TTL for response prompt
        promptTime = GetSecs - blockStartTime;

        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if isempty(cfg.answerkey) || isequal(temp(1), cfg.answerkey)
                    Eyelink('Message', 'KEY_PRESS_NOINSIGHT'); % log prompt onset to eyelink
                    sfun(); % send TTL for response
                    return;
                elseif isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end
    end
end