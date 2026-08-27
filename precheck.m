function precheck()
    % precheck.m — hardware connectivity check
    %   1. EyeLink connection
    %   2. Audio recording (records until trigger key pressed)
    %   3. TTL pulses (3x tfun, 3x sfun, 250 ms apart)
    %   4. Image loading
    %   5. EDF transfer

    addpath(genpath(fileparts(mfilename('fullpath'))));

    cfg     = config();
    edfFile = 'precheck';
    cfg.edfFile = edfFile;
    if ~exist(cfg.resultsDir, 'dir'); mkdir(cfg.resultsDir); end
    cfg.logDir = cfg.resultsDir;

    % =========================================================
    %% [1] EyeLink
    % =========================================================
    fprintf('\n=== [1/4] EyeLink ===\n');
    dummymode = eyelinkInit(edfFile);
    if dummymode == 0
        fprintf('[OK]   EyeLink connected.\n');
    else
        fprintf('[WARN] EyeLink not connected — running in dummy mode.\n');
    end

    % =========================================================
    %% [2] Audio setup (dialog before PTB window to avoid conflicts)
    % =========================================================
    fprintf('\n=== [2/4] Audio ===\n');
    InitializePsychSound(1);
    pahandle = [];

    allDevices   = PsychPortAudio('GetDevices');
    mask         = arrayfun(@(d) d.NrInputChannels > 0 && d.NrOutputChannels == 0, allDevices);
    inputDevices = allDevices(mask);

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
        error('test:cancelled', 'Cancelled by user.');
    end

    chosen = labels{sel};
    if contains(chosen, 'Continue without audio')
        fprintf('[INFO] No audio device selected — skipping audio test.\n');
    else
        channel = inputDevices(sel - 1).DeviceIndex;  % offset by 1: labels{1} is "Continue"
        try
            pahandle = PsychPortAudio('Open', channel, 2, [], [], 1);
            cfg.audioChannel = channel;
            fprintf('[OK]   Audio device opened: %s\n', chosen);
        catch audioErr
            fprintf('[ERROR] Failed to open audio device: %s\n', audioErr.message);
        end
    end

    % =========================================================
    %% Open PTB window
    % =========================================================
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1);
    screenNumber = max(Screen('Screens'));
    [window, ~] = PsychImaging('OpenWindow', screenNumber, 125/255);
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    [wwidth, hheight] = Screen('WindowSize', window);
    cfg.wwidth = wwidth; cfg.hheight = hheight; cfg.screenNumber = screenNumber;

    % TTL functions (or dummy printf wrappers in dummy mode)
    if dummymode == 0
        [tfun, sfun] = setup_ttl();
    else
        tfun = @() fprintf('[DUMMY] tfun pulse\n');
        sfun = @() fprintf('[DUMMY] sfun pulse\n');
    end

    % =========================================================
    %% Test: Audio recording
    % =========================================================
    fprintf('\n--- Audio recording test ---\n');
    if ~isempty(pahandle)
        msg = sprintf(['AUDIO TEST\n\n' ...
                       'Speak now. Recording is active.\n\n' ...
                       'Press  ''%s''  to stop.'], cfg.triggerkey);
        DrawFormattedText(window, msg, 'center', 'center', 0.2);
        Screen('Flip', window);

        % Allocate buffer and start recording
        PsychPortAudio('GetAudioData', pahandle, cfg.maxAnswerDuration);
        PsychPortAudio('Start', pahandle, 0, 0, 1);
        audioStartTime = GetSecs;

        % Wait for trigger key
        while true
            [~, keyCode] = KbWait(-3, 2);
            temp = KbName(keyCode);
            if iscell(temp); temp = temp{1}; end
            if ~isempty(temp) && isequal(temp(1), cfg.triggerkey)
                KbReleaseWait(-3);
                break;
            end
        end
        audioElapsed = GetSecs - audioStartTime;

        % Stop and save
        PsychPortAudio('Stop', pahandle, 0);
        [recordedAudio, ~] = PsychPortAudio('GetAudioData', pahandle);
        nSamples      = min(size(recordedAudio, 2), round(audioElapsed * 44100));
        recordedAudio = recordedAudio(:, 1:nSamples);
        audioFile     = fullfile(cfg.resultsDir, 'test_audio.wav');
        audiowrite(audioFile, recordedAudio', 44100);
        fprintf('[OK]   Recorded %.1f s  ->  %s\n', audioElapsed, audioFile);

        DrawFormattedText(window, sprintf('Audio saved: %.1f s', audioElapsed), 'center', 'center', 0.2);
        Screen('Flip', window);
        WaitSecs(1.5);
    else
        fprintf('[SKIP] No audio device.\n');
        DrawFormattedText(window, 'Audio: SKIPPED (no device selected)', 'center', 'center', 0.2);
        Screen('Flip', window);
        WaitSecs(1.5);
    end

    % =========================================================
    %% Test: TTL connections
    % =========================================================
    fprintf('\n--- TTL connection test ---\n');

    while true
        % --- tfun: 3 pulses ---
        for i = 1:3
            DrawFormattedText(window, ...
                sprintf('TTL CHECK\n\ntfun  —  pulse %d / 3', i), ...
                'center', 'center', 0.2);
            Screen('Flip', window);
            tfun();
            fprintf('[tfun] pulse %d sent\n', i);
            WaitSecs(0.25);   % on period
            WaitSecs(0.25);   % off period
        end

        WaitSecs(0.5);  % gap between tfun and sfun bursts

        % --- sfun: 3 pulses ---
        for i = 1:3
            DrawFormattedText(window, ...
                sprintf('TTL CHECK\n\nsfun  —  pulse %d / 3', i), ...
                'center', 'center', 0.2);
            Screen('Flip', window);
            sfun();
            fprintf('[sfun] pulse %d sent\n', i);
            WaitSecs(0.25);
            WaitSecs(0.25);
        end

        % Prompt: retry or continue
        DrawFormattedText(window, ...
            sprintf('TTL: 3 tfun + 3 sfun pulses sent.\n\nPress  ''%s''  to send again,  ''q''  to continue.', cfg.triggerkey), ...
            'center', 'center', 0.2);
        Screen('Flip', window);

        KbReleaseWait(-3);
        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if iscell(temp); temp = temp{1}; end
                if ~isempty(temp) && isequal(temp(1), cfg.triggerkey)
                    KbReleaseWait(-3);
                    fprintf('[TTL] Repeating pulses...\n');
                    break;  % inner — re-enter outer while loop
                elseif ~isempty(temp) && isequal(temp(1), 'q')
                    KbReleaseWait(-3);
                    fprintf('[TTL] Done.\n');
                    goto_next = true;
                    break;
                end
            end
        end

        if exist('goto_next', 'var') && goto_next
            clear goto_next;
            break;  % exit outer TTL loop
        end
    end

    % =========================================================
    %% Test: Image loading
    % =========================================================
    fprintf('\n--- Image loading test ---\n');
    cfg.taskMode = 1;
    cfg.subsetId = 'tutorial';

    DrawFormattedText(window, 'Loading images...', 'center', 'center', 0.2);
    Screen('Flip', window);

    try
        mooneyImages = load_mooney(window, cfg);
        numLoaded = length(mooneyImages);
        fprintf('[OK]   Loaded %d images.\n', numLoaded);
    catch loadErr
        fprintf('[ERROR] Image loading failed: %s\n', loadErr.message);
        DrawFormattedText(window, sprintf('Image load error:\n%s', loadErr.message), ...
            'center', 'center', 0.2);
        Screen('Flip', window);
        WaitSecs(2);
        numLoaded = 0;
    end

    % Step through images one per trigger key press; 'q' exits
    if numLoaded > 0
        imgIdx = 0;
        DrawFormattedText(window, ...
            sprintf('Loaded %d images.\n\nPress  ''%s''  to view each image,  ''q''  to continue.', ...
                numLoaded, cfg.triggerkey), ...
            'center', 'center', 0.2);
        Screen('Flip', window);

        KbReleaseWait(-3);
        while true
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                temp = KbName(keyCode);
                if iscell(temp); temp = temp{1}; end

                if ~isempty(temp) && isequal(temp(1), cfg.triggerkey)
                    KbReleaseWait(-3);
                    imgIdx = imgIdx + 1;
                    if imgIdx > numLoaded
                        imgIdx = 1;  % wrap around
                    end
                    Screen('DrawTexture', window, mooneyImages{imgIdx});
                    DrawFormattedText(window, ...
                        sprintf('%d / %d     ''%s'' = next,  ''q'' = done', imgIdx, numLoaded, cfg.triggerkey), ...
                        'center', hheight * 0.92, 0.2);
                    Screen('Flip', window);
                    fprintf('[IMG]  Showing image %d / %d\n', imgIdx, numLoaded);

                elseif ~isempty(temp) && isequal(temp(1), 'q')
                    KbReleaseWait(-3);
                    fprintf('[IMG]  Done (viewed %d images).\n', imgIdx);
                    break;
                end
            end
        end
    end

    % =========================================================
    %% EDF transfer & cleanup
    % =========================================================
    fprintf('\n--- EDF transfer ---\n');
    if dummymode == 0
        Eyelink('SetOfflineMode');
        WaitSecs(0.5);
        Eyelink('CloseFile');

        % Build minimal el struct (avoids running full calibration)
        el = EyelinkInitDefaults(window);
        el.backgroundcolour = [125/255 125/255 125/255];

        transfer_file(window, cfg, el, dummymode, edfFile);
        % transfer_file's internal cleanup calls sca + Eyelink('Shutdown')
    else
        fprintf('[SKIP] Dummy mode — no EDF to transfer.\n');
        Eyelink('Shutdown');

        if ~isempty(pahandle)
            PsychPortAudio('Close', pahandle);
        end
        sca;
    end

    fprintf('\n=== Test complete. ===\n');
end
