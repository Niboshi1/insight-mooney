function instruction_handswitch(window, cfg, tfun)
    % Load hand switch image
    img = load_png('assets/hand.png');
    img = imresize(img, cfg.targetWidth/size(img,2));
    imageTexture = Screen('MakeTexture', window, img);

    % Draw instruction
    instruct_text = 'Please switch the hand you are using to respond.';
    DrawFormattedText(window, instruct_text, 'center', 'center', .2);

    % Draw image
    Screen('DrawTexture', window, imageTexture);

    Screen('Flip', window);

    while true
        [~, keyCode] = KbWait(-3, 2);
        temp = KbName(keyCode);

        if isempty(cfg.triggerkey) || isequal(temp(1), cfg.triggerkey)
            break;
        end
    end

    if ~strcmp(tfun, 'NA')
        feval(tfun);
    end
end