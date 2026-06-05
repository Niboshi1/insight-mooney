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
    pahandle = PsychPortAudio('Open', cfg.audioChannel, 2, [], [], 1);

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

        % Recognition task
        % TODO: add hand switching every n trials
        for trial = 1:numImages

            % Hand switch instruction every 5 trials
            if mod(trial, 5) == 1
                instruction_handswitch(window, cfg, tfun);
            end

            % Mooney image prensentation
            [fixPresentationTime, stimulusPresentationTime, responseTime, stimEDFTime, keyResponse] = MooneyTrial( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, tfun, sfun);
            
            % Response
            [promptTime, quitNow] = ...
                responseTrial(trial, window, pahandle, cfg, keyResponse, blockStartTime, tfun, sfun);

            % Terminate
            if quitNow
                cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID);
                return;
            end

            fprintf(logFID, '%d\t%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t%d\n', ...
                trial, fixPresentationTime, stimulusPresentationTime, ...
                stimEDFTime, responseTime, promptTime, keyResponse);
        end

    else
        % Memory task
        % TODO: add hand switching every n trials
        for trial = 1:numImages
            % Mooney image presentation
            [fixPresentationTime, stimulusPresentationTime, stimEDFTime, responseTime, keyResponse] = MooneyMemoryTrial( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, tfun, sfun);

            % Response
            [promptFamiliarTime, keyPressFamiliar, promptRecognitionTime, ...
                keyPressRecognition, promptAnswerTime, quitNow] = ...
                responseMemoryTrial(trial, window, pahandle, cfg, keyResponse, blockStartTime, tfun, sfun);

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