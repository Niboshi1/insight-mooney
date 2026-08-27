function [promptFamiliarTime, keyPressFamiliar, promptRecognitionTime, keyPressRecognition, promptAnswerTime, quitNow] = phase2_response(trial, window, pahandle, cfg, blockStartTime, tfun, sfun)
    % Init outputs
    keyPressFamiliar = 0;
    promptRecognitionTime = Inf;
    keyPressRecognition = 0;
    promptAnswerTime = Inf;
    quitNow = false;

    % Fixation show + in center
    draw_cross(window, cfg);
    Eyelink('Message', 'CROSS_ONSET_POST_IMG'); % log fixation onset to eyelink
    tfun(); % send TTL for fixation onset
    WaitSecs(3 + randn); % mean 3s sd 1s

    % Prompt for familiarity
    resptext = 'Have you seen this image before? Yes (1) No (2)';
    DrawFormattedText(window, resptext, 'center', 'center', .2);
    Screen('Flip', window);
    Eyelink('Message', 'TEXT_PROMPT_QFAMILIAR');
    tfun(); % send TTL for familiarity prompt
    promptFamiliarTime = GetSecs - blockStartTime;
    
    while true
        [keyIsDown, ~, keyCode] = KbCheck(-3);
        if keyIsDown
            temp = KbName(keyCode);
            if ~isempty(temp) && any(temp(1) == '12')
                Eyelink('Message', 'KEY_PRESS_FAMILIAR');
                sfun(); % send TTL for response
                keyPressFamiliar = str2double(temp(1));
                KbReleaseWait(-3);
                waitSecs(0.3);  % brief pause
                break;
            elseif isequal(temp(1), 'q')
                quitNow = true;
                return;
            end
        end
    end

    % If answered familiar, ask for their previous response
    if keyPressFamiliar == 1
        % Fixation show + in center
        draw_cross(window, cfg);
        Eyelink('Message', 'CROSS_ONSET_PRE_QRECOGNITION'); % log fixation onset to eyelink
        tfun(); % send TTL for fixation onset
        WaitSecs(3 + randn); % mean 3s sd 1s

        % Ask if they were able to identify it
        resptext = 'Were you able to identify it previously? Yes (1) No (2)';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);
        Eyelink('Message', 'TEXT_PROMPT_QRECOGNITION'); % log prompt onset to eyelink
        tfun(); % send TTL for recognition prompt
        promptRecognitionTime = GetSecs - blockStartTime;
        
        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);                    
                if ~isempty(temp) && any(temp(1) == '12')
                    Eyelink('Message', 'KEY_PRESS_RECOGNITION');
                    sfun(); % send TTL for response
                    keyPressRecognition = str2double(temp(1));
                    KbReleaseWait(-3);
                    waitSecs(0.3);  % brief pause
                    break;
                elseif isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end
    end

    % If they said they recognize, prompt them to answer
    if keyPressRecognition == 1
        % Fixation show + in center
        draw_cross(window, cfg);
        Eyelink('Message', 'CROSS_ONSET_PRE_QANSWER'); % log fixation onset to eyelink
        tfun(); % send TTL for fixation onset
        WaitSecs(3 + randn); % mean 3s sd 1s

        % Prompt for vocal response
        resptext = 'Please answer what you saw';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);
        Eyelink('Message', 'TEXT_PROMPT_QANSWER'); % log prompt onset to eyelink
        tfun(); % send TTL for answer prompt
        promptAnswerTime = GetSecs - blockStartTime;

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
            if iscell(temp); temp = temp{1}; end  % KbName can return a cell on multi-key events

            if ~isempty(temp) && isequal(temp(1), cfg.triggerkey)
                break;
            end
        end
        audioElapsed = GetSecs - audioStartTime;

        % Stop audio recording and save actual elapsed audio (if device is available)
        if ~isempty(pahandle)
            PsychPortAudio('Stop', pahandle, 0);  % 0 = stop immediately, don't wait for drain
            [recordedAudio, ~] = PsychPortAudio('GetAudioData', pahandle);
            nSamples = min(size(recordedAudio, 2), round(audioElapsed * 44100));
            recordedAudio = recordedAudio(:, 1:nSamples);
            filename = fullfile(cfg.logDir, sprintf('%03d_memory.wav', trial));
            audiowrite(filename, recordedAudio', 44100);
        end

    end
end