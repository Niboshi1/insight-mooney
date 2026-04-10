function mooney_blocked()
    addpath(genpath(fileparts(mfilename('fullpath'))));

    cfg = config(); % load config

    taskmode = prompt_mode();
    if taskmode == 1
        prompt_subset();
    end

    %% STEP 1: Session setup
    % Session info and EDF file name
    dummymode  = check_dummy();
    [edfFile, subj, run] = get_edf_name(); %#ok<ASGLU>
    baseName = edfFile;

    % Setup TTL functions
    if dummymode == 1
        tfun = 'NA'; sfun = 'NA';
    else
        [tfun, sfun] = setup_ttl();
    end

    % Psychtoolbox setup
    PsychDefaultSetup(2);
    screenNumber = max(Screen('Screens'));
    [window, ~] = PsychImaging('OpenWindow', screenNumber, 12/255);
    [wwidth, hheight] = Screen('WindowSize', window);
    cfg.wwidth = wwidth; cfg.hheight = hheight; cfg.screenNumber = screenNumber;

    % Eyelink setup
    SetupSampleData(baseName, dummymode);
    el = SetupAndCalibrate(window, cfg, dummymode);

    % Load stimuli
    mooneyImages = load_mooney(window, cfg.stimDir, cfg.targetWidth);

    % Initialize logs
    logFID = init_logs(baseName, taskmode);

    %% STEP 2: Init experiment
    % Instructions and wait for trigger
    show_instructions_and_wait_trigger(window, taskmode, cfg.triggerkey, tfun);

    Screen('FillRect', window, 20); Screen('Flip', window);
    WaitSecs(3);

    blockStartTime = GetSecs;
    numImages = length(mooneyImages);

    %% STEP 3: Loop through trials
    % Check task mode
    if taskmode == 1

        % Recognition task
        for trial = 1:numImages
            % Mooney image prensentation
            [fixPresentationTime, stimulusPresentationTime, responseTime, stimEDFTime, keyResponse] = MooneyTrial( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, dummymode, tfun, sfun);
            
            % Response
            [promptTime, quitNow] = ...
                responseTrial(window, cfg, keyResponse, blockStartTime, tfun, sfun);

            % Terminate
            if quitNow
                cleanup_all(window, logFID);
                return;
            end

            fprintf(logFID, '%d\t%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t%d\n', ...
                trial, fixPresentationTime, stimulusPresentationTime, ...
                stimEDFTime, responseTime, promptTime, keyResponse);
        end

    else
        % Memory task
        for trial = 1:numImages
            % Mooney image presentation
            [fixPresentationTime, stimulusPresentationTime, stimEDFTime, responseTime, keyResponse] = MooneyMemoryTrialTest( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, dummymode, tfun, sfun);

            % Response
            [promptFamiliarTime, keyPressFamiliar, promptRecognitionTime, ...
                keyPressRecognition, promptAnswerTime, quitNow] = ...
                responseMemoryTrial(window, cfg, keyResponse, blockStartTime, tfun, sfun);

            % Terminate
            if quitNow
                cleanup_all(window, logFID);
                return;
            end

            fprintf(logFID, '%d\t%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t%d\t%.5f\t%d\t%.5f\t%d\n', ...
                trial, fixPresentationTime, stimulusPresentationTime, stimEDFTime, ...
                responseTime, promptFamiliarTime, keyPressFamiliar, promptRecognitionTime, ...
                keyPressRecognition, promptAnswerTime, keyResponse);
        end

    end

    %% STEP 4: Cleanup
    Eyelink('SetOfflineMode');
    Eyelink('Command', 'clear_screen 0');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    transferFile(window, cfg, el, dummymode, baseName);

    cleanup_all(window, logFID);

end