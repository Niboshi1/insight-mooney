function [promptFamiliarTime, keyPressFamiliar, promptRecognitionTime, keyPressRecognition, promptAnswerTime, quitNow] = responseMemoryTrial(window, cfg, keyResponse, blockStartTime, tfun, sfun)
    % Init outputs    
    promptFamiliarTime = Inf;
    keyPressFamiliar = 0;
    promptRecognitionTime = Inf;
    keyPressRecognition = 0;
    promptAnswerTime = Inf;
    quitNow = false;

    % Fixation show + in center
    draw_cross(window, cfg);
    fixPresentationTime = GetSecs - blockStartTime;
    WaitSecs(1 + randn); % mean 3s sd 1s

    % Prompt for familiarity
    resptext = 'Have you seen this image before? Yes (1) No (2)';
    DrawFormattedText(window, resptext, 'center', 'center', .2);
    Screen('Flip', window);
    tfun(); % send TTL for familiarity prompt
    promptFamiliarTime = GetSecs - blockStartTime;
    
    while true
        [keyIsDown, ~, keyCode] = KbCheck(-3);
        if keyIsDown
            temp = KbName(keyCode);
            if isempty(temp(1)) || isequal(temp(1), '1') || isequal(temp(1), '2')
                sfun(); % send TTL for response
                keyPressFamiliar = str2double(temp(1));
                KbReleaseWait(-3);
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
        fixPresentationTime = GetSecs - blockStartTime;
        WaitSecs(1 + randn); % mean 3s sd 1s

        % Ask if they were able to identify it
        resptext = 'Were you able to identify it previously? Yes (1) No (2)';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);
        tfun(); % send TTL for recognition prompt
        promptRecognitionTime = GetSecs - blockStartTime;
        
        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if isempty(temp(1)) || isequal(temp(1), '1') || isequal(temp(1), '2')
                    sfun(); % send TTL for response
                    keyPressRecognition = str2double(temp(1));
                    KbReleaseWait(-3);
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
        fixPresentationTime = GetSecs - blockStartTime;
        WaitSecs(1 + randn); % mean 3s sd 1s

        % Prompt for vocal response
        resptext = 'Please answer what you saw';
        DrawFormattedText(window, resptext, 'center', 'center', .2);
        Screen('Flip', window);
        tfun(); % send TTL for answer prompt
        promptAnswerTime = GetSecs - blockStartTime;
        
        promptStartTime = GetSecs;
        while (GetSecs - promptStartTime) < cfg.answerDuration
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if isequal(temp(1), 'q')
                    quitNow = true;
                    return;
                end
            end
        end

end