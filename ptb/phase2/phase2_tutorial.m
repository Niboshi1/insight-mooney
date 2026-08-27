function quitNow = phase2_tutorial(window, imageTexture, cfg)

    quitNow = false;

    % Fixation show + in center
    draw_cross(window, cfg);

    % Wait for keyboard trigger from experimenter
    while true
        [keyIsDown, ~, keyCode] = KbCheck(-3);
        if keyIsDown
            temp = KbName(keyCode);
            if ~isempty(temp) && isequal(temp(1), cfg.triggerkey)
                KbReleaseWait(-3);
                break;
            elseif ~isempty(temp) && isequal(temp(1), 'q')
                quitNow = true;
                return;
            end
        end
    end

    % Place Mooney image on screen
    Screen('DrawTexture', window, imageTexture);
    Screen('Flip', window);

    % Display image until the experimenter presses the trigger key
    % Allow subject to press answer key if they recognize it
    keyResponse = false;
    while true
        [keyIsDown, ~, keyCode] = KbCheck(-3);
        if keyIsDown
            temp = KbName(keyCode);
            if ~isempty(temp) && isequal(temp(1), cfg.triggerkey)
                KbReleaseWait(-3);
                break;
            elseif ~isempty(temp) && isequal(temp(1), 'q')
                quitNow = true;
                return;
            elseif ~keyResponse && ~isempty(temp) && isequal(temp(1), cfg.answerkey)
                keyResponse = true;
            end
        end
    end

    % Fixation after image
    draw_cross(window, cfg);
    WaitSecs(3 + randn); % mean 3s sd 1s

    % --- Familiarity prompt ---
    KbReleaseWait(-3);
    resptext = 'Have you seen this image before? Yes (1) No (2)';
    DrawFormattedText(window, resptext, 'center', 'center', .2);
    Screen('Flip', window);

    keyPressFamiliar = 0;
    while true
        [keyIsDown, ~, keyCode] = KbCheck(-3);
        if keyIsDown
            temp = KbName(keyCode);
            if ~isempty(temp) && any(temp(1) == '12')
                keyPressFamiliar = str2double(temp(1));
                KbReleaseWait(-3);
                WaitSecs(0.3);  % brief pause
                break;
            elseif ~isempty(temp) && isequal(temp(1), 'q')
                quitNow = true;
                return;
            end
        end
    end

    % --- If answered familiar, ask if they could identify it ---
    keyPressRecognition = 0;
    if keyPressFamiliar == 1

        % Fixation interval
        draw_cross(window, cfg);
        WaitSecs(3 + randn); % mean 3s sd 1s

        KbReleaseWait(-3);
        resptext = 'Were you able to identify it previously? Yes (1) No (2)';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);

        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && any(temp(1) == '12')
                    keyPressRecognition = str2double(temp(1));
                    KbReleaseWait(-3);
                    WaitSecs(0.3);  % brief pause
                    break;
                elseif ~isempty(temp) && isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end
    end

    % --- If they recognized it, prompt for vocal answer ---
    if keyPressRecognition == 1

        % Fixation interval
        draw_cross(window, cfg);
        WaitSecs(3 + randn); % mean 3s sd 1s

        % Prompt for vocal response
        resptext = 'Please answer what you saw';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);

        % Wait until triggerkey is pressed (no audio recording in tutorial)
        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && isequal(temp(1), cfg.triggerkey)
                    KbReleaseWait(-3);
                    break;
                elseif ~isempty(temp) && isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end

    % --- If not familiar or not recognized, prompt to proceed ---
    else
        resptext = 'Please press "1" key to proceed';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);

        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && isequal(temp(1), cfg.answerkey)
                    return;
                elseif ~isempty(temp) && isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end
    end

end
