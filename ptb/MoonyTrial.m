function [stimulusPresentationTime, fixPresentationTime] = MoonyTrial( ...
    trialno, n_trials, window, imageTexture, blockStartTime, cfg, el, dummymode, tfun, sfun, stimLogFID)

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
fixPresentationTime = GetSecs - blockStartTime;

Eyelink('Message', 'STIM_ONSET');
WaitSecs(0.3);
tfun();

% Moony image on screen
Screen('DrawTexture', window, imageTexture);
[~, trialStart] = Screen('Flip', window);
Eyelink('Message', 'SCENE_ONSET');

stimulusPresentationTime = trialStart - blockStartTime;
StimEDFtime = (Eyelink('TrackerTime')) * 1000;

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
tfun();

end