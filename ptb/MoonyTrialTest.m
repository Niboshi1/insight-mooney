function [stimulusPresentationTime, fixPresentationTime] = MoonyTrialTest( ...
    trialno, n_trials, window, imageTexture, blockStartTime, cfg, el, dummymode, tfun, sfun, stimLogFID)

% Fixation show + in center
DrawFormattedText(window, '+', 'center', 'center', .2);
Screen('Flip', window);
fixPresentationTime = GetSecs - blockStartTime;

WaitSecs(0.3);

% Moony image on screen
Screen('DrawTexture', window, imageTexture);
[~, trialStart] = Screen('Flip', window);

stimulusPresentationTime = trialStart - blockStartTime;

% wait 10 seconds or button press
startTime = GetSecs;
while (GetSecs - startTime) < cfg.imageDuration
    
    [keyIsDown, secs, keyCode] = KbCheck(-3);
    
    if keyIsDown
        temp = KbName(keyCode);
        
        if isempty(cfg.triggerkey) || isequal(temp(1), cfg.triggerkey)
            break;  % Exit immediately on key press
        end
    end
end

end