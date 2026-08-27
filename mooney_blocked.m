function mooney_blocked()
    addpath(genpath(fileparts(mfilename('fullpath'))));

    %% STEP 1: Session setup
    % Load configuration
    cfg = config();

    % Get session info
    [edfFile, taskMode, subsetId, tutorial] = prompt_info();
    cfg.edfFile = edfFile; cfg.taskMode = taskMode; cfg.subsetId = subsetId; cfg.tutorial = tutorial;

    % Init logs
    [logFID, logDir] = init_logs(edfFile, taskMode, subsetId, cfg.resultsDir);
    cfg.logDir = logDir;

    % Init Eyelink
    dummymode = eyelinkInit(edfFile);

    % Init audio — pick device from list
    InitializePsychSound(1);
    pahandle = [];

    allDevices   = PsychPortAudio('GetDevices');
    mask         = arrayfun(@(d) d.NrInputChannels > 0 && d.NrOutputChannels == 0, allDevices);
    inputDevices = allDevices(mask);

    while isempty(pahandle)
        if isempty(inputDevices)
            labels = {'— Continue without audio —'};
        else
            deviceLabels = arrayfun(@(d) sprintf('[%d]  %s  (%s)', ...
                d.DeviceIndex, d.DeviceName, d.HostAudioAPIName), ...
                inputDevices, 'UniformOutput', false);
            labels = [{'— Continue without audio —'}, deviceLabels];
        end

        [sel, ok] = listdlg( ...
            'ListString',   labels, ...
            'SelectionMode','single', ...
            'Name',         'Audio Setup', ...
            'PromptString', 'Select an audio input device:', ...
            'OKString',     'Select', ...
            'ListSize',     [420 150]);

        if ~ok || isempty(sel)
            error('mooney_blocked:audioOpenFailed', 'Audio setup cancelled.');
        end

        chosen = labels{sel};
        if contains(chosen, 'Continue without audio')
            fprintf('Continuing without audio.\n');
            break;
        else
            channel = inputDevices(sel).DeviceIndex;
            try
                pahandle = PsychPortAudio('Open', channel, 2, [], [], 1);
                cfg.audioChannel = channel;
            catch audioErr
                fprintf('\nFailed to open device [%d]: %s\nPlease select another device.\n', ...
                    channel, audioErr.message);
                % pahandle stays [] — loop re-shows the list
            end
        end
    end

    % Init Psychtoolbox window — opened after audio dialogs to avoid conflicts
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 0);
    screenNumber = max(Screen('Screens'));
    [window, ~] = PsychImaging('OpenWindow', screenNumber, 125/255);
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
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
   
    % Load stimuli
    mooneyImages = load_mooney(window, cfg);

    % Decide which hand to start with
    hands = {'left', 'right'};
    cfg.initHand = hands{randi(2)};   % {} extracts the string; () would return a cell
    cfg.handNow  = cfg.initHand;

    %% STEP 2: Init experiment
    % Instructions and wait for trigger
    instruction_init(window, taskMode, cfg.triggerkey, tfun, tutorial);
    draw_cross(window, cfg);
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
        phase1_run(numImages, window, mooneyImages, blockStartTime, cfg, tfun, sfun, pahandle, el, dummymode, edfFile, logFID)

    else
        % Memory task phase 2
        phase2_run(numImages, window, mooneyImages, blockStartTime, cfg, tfun, sfun, pahandle, el, dummymode, edfFile, logFID);

    end
    
    % Stop recording and wait
    if dummymode == 0
        WaitSecs(0.1);
        Eyelink('StopRecording');
    end

    %% STEP 4: Cleanup
    cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID);

end