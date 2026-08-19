function mooney_blocked()
    addpath(genpath(fileparts(mfilename('fullpath'))));

    %% STEP 1: Session setup
    % Load configuration
    cfg = config();

    % Get session info
    [edfFile, taskMode, subsetId] = prompt_info();
    cfg.edfFile = edfFile; cfg.taskMode = taskMode; cfg.subsetId = subsetId;

    % Init logs
    [logFID, logDir] = init_logs(edfFile, taskMode, subsetId, cfg.resultsDir);
    cfg.logDir = logDir;

    % Init Eyelink
    dummymode = eyelinkInit(edfFile);

    % Init Psychtoolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 0);
    screenNumber = max(Screen('Screens'));
    [window, ~] = PsychImaging('OpenWindow', screenNumber, 125/255);
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    [wwidth, hheight] = Screen('WindowSize', window);
    cfg.wwidth = wwidth; cfg.hheight = hheight; cfg.screenNumber = screenNumber;

    % Init audio
    InitializePsychSound(1);
    try
        pahandle = PsychPortAudio('Open', cfg.audioChannel, 2, [], [], 1);
    catch audioErr
        fprintf('\nERROR: Failed to open audio device (channel %d):\n  %s\n', cfg.audioChannel, audioErr.message);
        fprintf('\nAvailable audio input devices:\n');
        devices = PsychPortAudio('GetDevices');
        for d = 1:length(devices)
            fprintf('  [%d] %s  (inputs: %d, hostAPI: %s)\n', ...
                devices(d).DeviceIndex, devices(d).DeviceName, ...
                devices(d).NrInputChannels, devices(d).HostAudioAPIName);
        end
        sca;
        error('mooney_blocked:audioOpenFailed', 'Could not open audio input. See device list above.');
    end

    % Init TTL connections
    if dummymode == 0
        [tfun, sfun] = setup_ttl();
    else
        tfun = 'NA'; sfun = 'NA';
    end

    % Eyelink setup and calibration
    el = eyelinkCalibrate(window, cfg, dummymode);
   
    % Load stimuli
    mooneyImages = load_mooney(window, cfg);

    % Decide which hand to start with
    hands = {'left', 'right'};
    cfg.initHand = hands(randi(2));
    cfg.handNow = cfg.initHand;

    %% STEP 2: Init experiment
    % Instructions and wait for trigger
    instruction_init(window, taskMode, cfg.triggerkey, tfun);

    Screen('FillRect', window, 125/255); Screen('Flip', window);
    WaitSecs(3);

    blockStartTime = GetSecs;
    numImages = length(mooneyImages);

    %% STEP 3: Loop through trials
        
    if dummymode == 0
        Eyelink('SetOfflineMode');
        WaitSecs(0.5);
        Eyelink('StartRecording');
    end

    % Check task mode
    if taskMode == 1

        % Recognition task phase 1
        for trial = 1:numImages

            % Hand switch instruction every 5 trials
            if mod(trial, 5) == 1
                instruction_handswitch(window, cfg, tfun);
                if strcmp(cfg.handNow, 'left')
                    cfg.handNow = 'right';
                elseif strcmp(cfg.handNow, 'right')
                    cfg.handNow = 'left';
                else
                    Error('Current hand not set in config');
                end
            end

            % Mooney image prensentation
            [fixPresentationTime, stimulusPresentationTime, stimEDFTime, responseTime, keyResponse] = phase1_recog( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, tfun, sfun);
            
            % Response
            [promptTime, suddennessRating, suddennessTime, confidenceRating, confidenceTime, quitNow] = ...
                phase1_response(trial, window, pahandle, cfg, keyResponse, blockStartTime, tfun, sfun);

            % Terminate
            if quitNow
                cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID);
                return;
            end

            fprintf(logFID, '%d\t%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t%d\t%.5f\t%d\t%.5f\t%d\n', ...
                trial, fixPresentationTime, stimulusPresentationTime, ...
                stimEDFTime, responseTime, promptTime, keyResponse, ...
                suddennessTime, suddennessRating, confidenceTime, confidenceRating);
        end

    elif taskMode == 2
        % Memory task phase 2
        for trial = 1:numImages

            % Hand switch instruction every 5 trials
            if mod(trial, 5) == 1
                instruction_handswitch(window, cfg, tfun);
                if strcmp(cfg.handNow, 'left')
                    cfg.handNow = 'right';
                elseif strcmp(cfg.handNow, 'right')
                    cfg.handNow = 'left';
                else
                    Error('Current hand not set in config');
                end
            end

            % Mooney image presentation
            [fixPresentationTime, stimulusPresentationTime, stimEDFTime, responseTime, keyResponse] = phase2_recog( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, tfun, sfun);

            % Response
            [promptFamiliarTime, keyPressFamiliar, promptRecognitionTime, ...
                keyPressRecognition, promptAnswerTime, quitNow] = ...
                phase2_response(trial, window, pahandle, cfg, keyResponse, blockStartTime, tfun, sfun);

            % Terminate
            if quitNow
                cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID);
                return;
            end

            fprintf(logFID, '%d\t%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t%d\t%.5f\t%d\t%.5f\t%d\n', ...
                trial, fixPresentationTime, stimulusPresentationTime, stimEDFTime, ...
                responseTime, promptFamiliarTime, keyPressFamiliar, promptRecognitionTime, ...
                keyPressRecognition, promptAnswerTime, keyResponse);
        end

    end
    
    % Stop recording and wait
    if dummymode == 0
        WaitSecs(0.1);
        Eyelink('StopRecording');
    end

    %% STEP 4: Cleanup
    cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID);

end