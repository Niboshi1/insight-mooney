function quitNow = phase1_tutorial(window, mooneyImages, cfg, tfun)
    % PHASE1_TUTORIAL  Step-by-step walkthrough of the recognition task.
    %
    %   quitNow = phase1_tutorial(window, mooneyImages, cfg, tfun)
    %
    % Every step is advanced by the experimenter with cfg.triggerkey (the
    % subject only presses cfg.answerkey on the image and the 1-5 rating
    % keys).  Press 'q' at any time to abort.
    %
    % Flow:
    %   1. Hand instruction page (explains that the response hand alternates)
    %   2. Image-type page: colour -> grayscale -> binarized examples
    %   3. Sample trials (cfg.phase1.tutorialTrials), each:
    %        fixation -> image (scaled, with instruction at top) -> fixation
    %        -> vocal answer prompt -> suddenness rating -> confidence rating
    %        (or "press 1 to proceed" if the subject did not press 1)
    %      with longer explanations of the ratings than in the real trial.

    c = cfg.phase1;
    quitNow = false;
    textCol = cfg.textColor / 255;
    cx = cfg.wwidth / 2;
    cy = cfg.hheight / 2;
    nTrials = min(c.tutorialTrials, numel(mooneyImages));

    %% 1. Hand instruction (explained once, then alternates every N sample trials)
    handIntro = ['In this task you will be told which hand to use for your responses.\n' ...
                 'The hand will alternate during the session -\n' ...
                 'always check the instruction before you continue.'];
    instruction_handswitch(window, cfg, tfun, handIntro);
    cfg.handNow = other_hand(cfg.handNow);

    %% 2. Image types
    texCol  = make_example(window, cfg, c.tutorialImgCol);
    texGray = make_example(window, cfg, c.tutorialImgGray);
    texBin  = make_example(window, cfg, c.tutorialImgBin);
    exampleTex = [texCol, texGray, texBin];

    % Show the three example types one after another, then together
    captions = {'Color', 'Grayscale', 'Black and white (binarized)'};
    explain  = {'This is a normal color photograph.', ...
                'First, imagine it with the color removed: a grayscale image.', ...
                ['Finally, imagine it reduced to only black and white.\n' ...
                 'In this task you will see images like this one.']};
    for k = 1:3
        draw_examples(window, cfg, exampleTex(1:k), captions(1:k));
        draw_text(window, textCol, explain{k}, cfg.hheight * 0.08);
        Screen('Flip', window);
        [~, quitNow] = wait_key(cfg.triggerkey);
        if quitNow; close_all(exampleTex); return; end
    end
    close_all(exampleTex);

    %% 3. Sample trials
    for trial = 1:nTrials
        if trial > 1 && mod(trial - 1, c.tutorialSwitchEvery) == 0
            instruction_handswitch(window, cfg, tfun);
            cfg.handNow = other_hand(cfg.handNow);
        end

        % --- Fixation ---
        draw_marker(window, cfg, cx, cy);
        if trial == 1
            draw_text(window, textCol, ['Each trial starts with a cross.\n' ...
                'Keep your eyes on the cross until the image appears.'], cfg.hheight * 0.2);
        end
        Screen('Flip', window);
        [~, quitNow] = wait_key(cfg.triggerkey);
        if quitNow; return; end

        % --- Mooney image (scaled down to leave room for the instruction) ---
        tex = mooneyImages{trial};
        texRect = Screen('Rect', tex);
        dstRect = CenterRectOnPointd(texRect * c.tutorialScale, cx, cy);
        Screen('DrawTexture', window, tex, [], dstRect);
        draw_text(window, textCol, sprintf(['As soon as you are aware of what the image shows, press ''%s''.\n' ...
            'If you do not recognize it, do not press anything.'], cfg.answerkey), cfg.hheight * 0.03);
        Screen('Flip', window);

        keyResponse = false;
        while true
            [key, quitNow] = wait_key([cfg.triggerkey cfg.answerkey]);
            if quitNow; return; end
            if key == cfg.answerkey
                keyResponse = true;   % subject recognized the image; keep showing it
            else
                break;                % experimenter ends the image
            end
        end

        % --- Fixation after image ---
        draw_marker(window, cfg, cx, cy);
        Screen('Flip', window);
        [~, quitNow] = wait_key(cfg.triggerkey);
        if quitNow; return; end

        if keyResponse
            %% Solved: vocal answer, then suddenness and confidence ratings
            draw_text(window, textCol, ['You pressed ''1'': you recognized the image.\n\n' ...
                'Please say out loud what you saw.'], 'center');
            Screen('Flip', window);
            [~, quitNow] = wait_key(cfg.triggerkey);
            if quitNow; return; end

            draw_marker(window, cfg, cx, cy);
            Screen('Flip', window);
            [~, quitNow] = wait_key(cfg.triggerkey);
            if quitNow; return; end

            % Suddenness
            DrawFormattedText(window, ['In a scale of 1-5, how did the solution come to you?\n\n' ...
                'sudden (popped out) <-   1   2   3   4   5   -> gradual (figured it out)'], ...
                'center', 'center', textCol);
            draw_text(window, textCol, ['If you recognized the image, and pressed "1"\n' ...
                'you will see 2 questions.\n' ...
                'This asks you to rate how sudden the solution came to you.\n' ...
                'Answer by pressing corresponding key.'], cfg.hheight * 0.08);
            Screen('Flip', window);
            [~, quitNow] = wait_key('12345');
            if quitNow; return; end

            draw_marker(window, cfg, cx, cy);
            Screen('Flip', window);
            [~, quitNow] = wait_key(cfg.triggerkey);
            if quitNow; return; end

            % Confidence
            DrawFormattedText(window, ['In a scale of 1-5, how confident are you in your answer?\n\n' ...
                'Not confident <-   1   2   3   4   5   -> Very confident'], ...
                'center', 'center', textCol);
            draw_text(window, textCol, ['This second question asks you to rate how confident you are with the solution.\n' ...
                'Answer by pressing corresponding key.'], cfg.hheight * 0.08);
            Screen('Flip', window);
            [~, quitNow] = wait_key('12345');
            if quitNow; return; end
        else
            %% Not solved: just proceed
            draw_text(window, textCol, ['You did not press ''1'': you did not recognize the image.\n\n' ...
                'That is fine - many images are hard.\n' ...
                'Please press ''1'' to proceed to the next trial.'], 'center');
            Screen('Flip', window);
            [~, quitNow] = wait_key(cfg.answerkey);
            if quitNow; return; end
        end
    end

    %% Done
    draw_text(window, textCol, ['This is the end of the tutorial.\n\n' ...
        'Experimenter: press trigger key to finish.'], 'center');
    Screen('Flip', window);
    [~, quitNow] = wait_key(cfg.triggerkey);
end

%% ---------------------------------------------------------------------
%% Local helpers
%% ---------------------------------------------------------------------

function [key, quitNow] = wait_key(allowed)
    % Wait for a key whose first character is in 'allowed'; 'q' aborts.
    key = '';
    quitNow = false;
    KbReleaseWait(-3);
    while true
        [down, ~, keyCode] = KbCheck(-3);
        if down
            name = KbName(keyCode);
            if iscell(name); name = name{1}; end
            if ~isempty(name)
                if name(1) == 'q'
                    quitNow = true;
                    KbReleaseWait(-3);
                    return;
                elseif any(name(1) == allowed)
                    key = name(1);
                    KbReleaseWait(-3);
                    return;
                end
            end
        end
        WaitSecs(0.005);
    end
end

function draw_text(window, textCol, str, y)
    % Draw (multi-line) text horizontally centred at vertical position y.
    DrawFormattedText(window, sprintf(str), 'center', y, textCol, 90);
end

function tex = make_example(window, cfg, fileName)
    path = fullfile(cfg.phase1.tutorialImgDir, fileName);
    if ~exist(path, 'file')
        error('phase1_tutorial:missingImage', 'Tutorial example image not found: %s', path);
    end
    tex = Screen('MakeTexture', window, load_png(path));
end

function draw_examples(window, cfg, textures, captions)
    % Draw the example images in a row at 28% screen width each, with captions.
    n = numel(textures);
    w = cfg.wwidth * 0.28;
    gap = cfg.wwidth * 0.04;
    total = 3 * w + 2 * gap;   % layout always reserves three slots
    x0 = (cfg.wwidth - total) / 2;
    for k = 1:n
        r = Screen('Rect', textures(k));
        h = w * r(4) / r(3);
        left = x0 + (k - 1) * (w + gap);
        top = cfg.hheight / 2 - h / 2;
        Screen('DrawTexture', window, textures(k), [], [left top left + w top + h]);
        DrawFormattedText(window, captions{k}, left + w / 2 - RectWidth(Screen('TextBounds', window, captions{k})) / 2, ...
            top + h + 30, cfg.textColor / 255);
    end
end

function close_all(textures)
    Screen('Close', textures);
end

function hand = other_hand(hand)
    if strcmp(hand, 'left')
        hand = 'right';
    elseif strcmp(hand, 'right')
        hand = 'left';
    else
        error('phase1_tutorial:badHand', 'cfg.handNow must be ''left'' or ''right''.');
    end
end
