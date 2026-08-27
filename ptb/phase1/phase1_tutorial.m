function quitNow = phase1_tutorial(window, imageTexture, cfg)

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

    % Fixation show after image
    draw_cross(window, cfg);
    WaitSecs(3 + randn); % mean 3s sd 1s

    % If the participant was able to solve the Mooney image (keyResponse = true)
    if keyResponse
        % -- Vocal response --
        resptext = 'Please answer what you saw';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);

        % Wait until triggerkey is pressed
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

        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && any(temp(1) == '12345')
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
        
        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if ~isempty(temp) && any(temp(1) == '12345')
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