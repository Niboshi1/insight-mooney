function instruction_handswitch(window, cfg, tfun)
    % Load image, set instruction text, and compute image rect — all from handNow
    imgW_pre = cfg.targetWidth;
    cx     = cfg.wwidth / 2;
    margin = 50;

    if strcmp(cfg.handNow, 'left')
        img          = load_png('assets/handL.png');
        instruct_text = 'Please use your left hand for response.';
        img = imresize(img, imgW_pre/size(img,2)/2);
        imgW = size(img, 2);  imgH = size(img, 1);
        imgRect = [cx - imgW - margin, cfg.hheight - imgH - margin, ...
                   cx - margin,        cfg.hheight - margin];
    elseif strcmp(cfg.handNow, 'right')
        img          = load_png('assets/handR.png');
        instruct_text = 'Please use your right hand for response.';
        img = imresize(img, imgW_pre/size(img,2)/2);
        imgW = size(img, 2);  imgH = size(img, 1);
        imgRect = [cx + margin,        cfg.hheight - imgH - margin, ...
                   cx + imgW + margin, cfg.hheight - margin];
    else
        error('instruction_handswitch: cfg.handNow must be ''left'' or ''right''');
    end

    imageTexture = Screen('MakeTexture', window, img);
    DrawFormattedText(window, instruct_text, 'center', 'center', .2);
    Screen('DrawTexture', window, imageTexture, [], imgRect);
    Screen('Flip', window);

    while true
        [~, keyCode] = KbWait(-3, 2);
        temp = KbName(keyCode);

        if isempty(cfg.triggerkey) || (~isempty(temp) && isequal(temp(1), cfg.triggerkey))
            break;
        end
    end

    if ~strcmp(tfun, 'NA')
        feval(tfun);
    end
end