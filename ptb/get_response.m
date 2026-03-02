function [resp, rt, onset, quitNow] = get_response(window, memorymode, responseDuration, blockStartTime)
    quitNow = false;

    if memorymode == 1
        resptext = 'Press 1 for New, 2 for Unsure, or 3 for Old';
    else
        resptext = 'Press 1 for Like, 2 for Neutral, or 3 for Dislike';
    end

    DrawFormattedText(window, resptext, 'center', 'center', .2);
    Screen('Flip', window);
    onset = GetSecs - blockStartTime;

    startResponse = GetSecs;
    resp = '';
    rt = Inf;

    while GetSecs - startResponse < responseDuration
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            rt = GetSecs - startResponse;
            pressedKey = KbName(find(keyCode)); %#ok<FNDSB>
            resp = pressedKey;

            if strcmpi(pressedKey, 'Q')
                quitNow = true;
                return;
            end
        end
    end
end