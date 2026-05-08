function [promptTime, quitNow] = responseTrial(window, cfg, keyResponse, blockStartTime, tfun, sfun)
    quitNow = false;

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

    else % if not able to solve
        % Prompt for key press TODO: decide on response key
        resptext = 'Please press key to proceed';
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