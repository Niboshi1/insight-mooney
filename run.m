function run()
    addpath(genpath(fileparts(mfilename('fullpath'))));

    %% STEP 1: Session setup
    % Load configuration
    % Shared and task-specific configurations
    cfg = config();
    cfg = phase1_config(cfg);
    cfg = phase2_config(cfg);

    % Get session info
    [edfFile, taskMode, subsetId, tutorial, subj, runNum] = prompt_info();
    cfg.edfFile = edfFile; cfg.taskMode = taskMode; cfg.subsetId = subsetId; cfg.tutorial = tutorial;
    cfg.subj = subj; cfg.runNum = runNum;

    % Init logs
    if ~exist(cfg.resultsDir, 'dir'); mkdir(cfg.resultsDir); end
    cfg.logDir = init_logs(edfFile, taskMode, subsetId, cfg.resultsDir);

    if strcmp(taskMode, 'phase1')
        logFID = open_log(cfg, sprintf('_rec_set%s_log.txt', subsetId), ...
            ['Trial\tHandNow\tFixation_Onset\tStimulus_Onset\tStimulus_Onset_EDF\tPT_Response_Onset\t' ...
             'Prompt_Post_Response\tAnswered\tPrompt_Suddenness\tPT_Suddenness\tPrompt_Confidence\tPT_Confidence\n']);
    else
        logFID = open_log(cfg, sprintf('_mem_set%s_log.txt', subsetId), ...
            ['Trial\tHandNow\tFixation_Onset_GLOB\tStimulus_Onset_GLOB\tStimulus_Onset_EDF_Time\tResponse_Onset\t' ...
             'Prompt_Familiar_Onset\tKeyFamiliar\tPrompt_Recognition_Onset\tKeyRecognition\tPrompt_Answer_Onset\tAnswered\n']);
    end

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
            error('run:audioOpenFailed', 'Audio setup cancelled.');
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
    Screen('Preference', 'SkipSyncTests', cfg.skipsynctest);
    screenNumber = max(Screen('Screens'));
    [window, ~] = PsychImaging('OpenWindow', screenNumber, cfg.itiGray / 255);
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    [wwidth, hheight] = Screen('WindowSize', window);
    cfg.wwidth = wwidth; cfg.hheight = hheight; cfg.screenNumber = screenNumber;
    cfg.ifi = Screen('GetFlipInterval', window);

    fprintf('Screen size:    %d x %d px\n', wwidth, hheight);
    fprintf('Frame interval: %.2f ms (%.1f Hz)\n', cfg.ifi*1000, 1/cfg.ifi);

    % Init TTL connections — real or dummy printf wrappers
    if dummymode == 0
        [tfun, sfun] = setup_ttl();
    else
        tfun = @(msg) fprintf('[TTL-event] %s\n', msg);
        sfun = @(msg) fprintf('[TTL-response] %s\n', msg);
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
    instruction_init(window, cfg, tfun);
    draw_marker(window, cfg, cfg.wwidth/2, cfg.hheight/2);
    Screen('Flip', window);
    WaitSecs(3);

    blockStartTime = GetSecs;
    numImages = length(mooneyImages);

    %% STEP 3: Loop through trials
        
    if dummymode == 0
        Eyelink('SetOfflineMode');
        WaitSecs(0.5);
        Eyelink('StartRecording');
    end

    Eyelink('Message', 'EXPERIMENT_START SUBJ %s RUN %s TASK %s', subj, runNum, taskMode);

    if strcmp(taskMode, 'phase1')
        % Recognition task phase 1
        phase1_run(numImages, window, mooneyImages, blockStartTime, cfg, tfun, sfun, pahandle, logFID);
    elseif strcmp(taskMode, 'phase2')
        % Memory task phase 2
        phase2_run(numImages, window, mooneyImages, blockStartTime, cfg, tfun, sfun, pahandle, logFID);
    end

    Eyelink('Message', 'EXPERIMENT_END');

    % Stop recording and wait
    if dummymode == 0
        WaitSecs(0.1);
        Eyelink('StopRecording');
    end

    %% STEP 4: Cleanup
    cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID);

end