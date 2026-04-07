function mooney_blocked()
addpath(genpath(fileparts(mfilename('fullpath'))));

cfg = config(); % load config

taskmode = prompt_mode();
if taskmode == 1
    prompt_subset();
end

% ---- Session naming ----
if cfg.ptbOnly
    % PTB-only: no EDF, no Eyelink. Use timestamped base name for logs.
    baseName = ['results/ptb_' datestr(now,'yyyymmdd_HHMMSS')];
    subj = 'NA'; run = '1'; %#ok<NASGU>
    dummymode = 1;
else
    dummymode  = check_dummy();
    [edfFile, subj, run] = get_edf_name(); %#ok<ASGLU>
    baseName = edfFile;
end

% ---- TTL setup ----
if cfg.ptbOnly
    tfun = 'NA';
    sfun = 'NA';
else
    [tfun, sfun] = setup_ttl();
end

% ---- PTB init ----
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens'));
[window, ~] = PsychImaging('OpenWindow', screenNumber, 12/255);
[wwidth, hheight] = Screen('WindowSize', window);
cfg.wwidth = wwidth; cfg.hheight = hheight; cfg.screenNumber = screenNumber;

% ---- EyeLink only if not PTB-only ----
if ~cfg.ptbOnly
    SetupSampleData(baseName, dummymode);
    el = SetupAndCalibrate(window, cfg, dummymode);
else
    el = []; % placeholder
    HideCursor(screenNumber);
    ListenChar(-1);
end

% ---- Mooney images init ----
mooneyImages = load_mooney(window, cfg.stimDir, cfg.targetWidth);

% ---- Logs init ----
logFID = init_logs(baseName, taskmode);

% ---- Instructions + trigger ----
show_instructions_and_wait_trigger(window, taskmode, cfg.triggerkey, tfun);

Screen('FillRect', window, 20); Screen('Flip', window);
WaitSecs(3);

blockStartTime = GetSecs;
numImages = length(mooneyImages);


% Check task mode
if taskmode == 1
    for trial = 1:numImages
        % Mooney image prensentation
        if cfg.ptbOnly
            [fixPresentationTime, stimulusPresentationTime, responseTime, keyResponse] = MooneyTrialTest( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, el, dummymode, tfun, sfun);
        else
            [stimulusPresentationTime, fixPresentationTime] = MooneyTrial( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, el, dummymode, tfun, sfun);
            Screen('FillRect', window, 20); Screen('Flip', window);
            WaitSecs(0.1);
            Eyelink('StopRecording');
            WaitSecs(cfg.blankDuration - 0.1);
        end
        
        % Response
        [promptTime, quitNow] = ...
            responseTrial(window, cfg, keyResponse, blockStartTime);

        % Terminate
        if quitNow
            cleanup_all(window, cfg.ptbOnly, logFID);
            return;
        end

        fprintf(logFID, '%d\t%.5f\t%.5f\t%.5f\t%.5f\t%d\n', ...
            trial, fixPresentationTime, stimulusPresentationTime, ...
            responseTime, promptTime, keyResponse);
    end

else
    for trial = 1:numImages
        % Mooney image prensentation
        if cfg.ptbOnly
            [fixPresentationTime, stimulusPresentationTime, responseTime, keyResponse] = MooneyMemoryTrialTest( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, el, dummymode, tfun, sfun);
        else
            [stimulusPresentationTime, fixPresentationTime] = MooneyTrial( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, el, dummymode, tfun, sfun);
            Screen('FillRect', window, 20); Screen('Flip', window);
            WaitSecs(0.1);
            Eyelink('StopRecording');
            WaitSecs(cfg.blankDuration - 0.1);
        end
        
        % Response
        [promptFamiliarTime, keyPressFamiliar, promptRecognitionTime, ...
            keyPressRecognition, promptAnswerTime, quitNow] = ...
            responseMemoryTrial(window, cfg, keyResponse, blockStartTime);

        % Terminate
        if quitNow
            cleanup_all(window, cfg.ptbOnly, logFID);
            return;
        end

        fprintf(logFID, '%d\t%.5f\t%.5f\t%.5f\t%.5f\t%d\t%.5f\t%d\t%.5f\t%d\n', ...
            trial, fixPresentationTime, stimulusPresentationTime, ...
            responseTime, promptFamiliarTime, keyPressFamiliar, promptRecognitionTime, ...
            keyPressRecognition, promptAnswerTime, keyResponse);
    end

end

% ---- End ----
if ~cfg.ptbOnly
    Eyelink('SetOfflineMode');
    Eyelink('Command', 'clear_screen 0');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    transferFile(window, cfg, el, dummymode, baseName);
end

cleanup_all(window, cfg.ptbOnly, logFID);

end