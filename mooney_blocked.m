function mooney_blocked()
    addpath(genpath(fileparts(mfilename('fullpath'))));

    %% STEP 1: Session setup
    % Load configuration
    cfg = config();

    % Get session info
    [edfFile, taskMode, subsetId] = prompt_info();

    % Init Eyelink
    dummymode = eyelinkInit(cfg, edfFile);

    % Init Psychtoolbox
    PsychDefaultSetup(2);
    screenNumber = max(Screen('Screens'));
    [window, ~] = PsychImaging('OpenWindow', screenNumber, 125/255);
    [wwidth, hheight] = Screen('WindowSize', window);
    cfg.wwidth = wwidth; cfg.hheight = hheight; cfg.screenNumber = screenNumber;

    % Init TTL connections
    if dummymode == 0
        [tfun, sfun] = setup_ttl();
    else
        tfun = 'NA'; sfun = 'NA';
    end

    % Eyelink setup and calibration
    el = eyelinkCalibrate(window, cfg, dummymode);
   
    % Init logs
    logFID = init_logs(edfFile, taskMode);

    % Load stimuli
    mooneyImages = load_mooney(window, cfg.stimDir, cfg.targetWidth);

    %% STEP 2: Init experiment
    % Instructions and wait for trigger
    show_instruction(window, taskMode, cfg.triggerkey, tfun);

    Screen('FillRect', window, 125/255); Screen('Flip', window);
    WaitSecs(3);

    blockStartTime = GetSecs;
    numImages = length(mooneyImages);

    %% STEP 3: Loop through trials
    % Check task mode
    if taskMode == 1

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
            [fixPresentationTime, stimulusPresentationTime, stimEDFTime, responseTime, keyResponse] = MooneyMemoryTrial( ...
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

    % Shutdown Eyelink
    Eyelink('SetOfflineMode');
    Eyelink('Command', 'clear_screen 0');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    transferFile(window, cfg, el, dummymode, baseName);
    try Eyelink('Shutdown'); catch, end    % Shut down Eyelink connection
    try Screen('CloseAll'); catch, end     % Close all open screens using Psychtoolbox
    ListenChar(0);                         % Re-enable keyboard input
    ShowCursor;                            % Show the cursor (it may be hidden during the experiment)
    if ~IsOctave; commandwindow; end       % Open the command window if not running in Octave
    if ~isempty(logFID) && logFID > 0; fclose(logFID); end   % Close the log file if the file ID is valid

end