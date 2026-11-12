function instruction_handswitch(window, cfg, tfun, headerText)
    % Load image, set instruction text, and compute image rect — all from handNow
    % Optional headerText is drawn near the top of the screen (tutorial explanations).
    if nargin < 4; headerText = ''; end
    imgW_pre = cfg.targetWidth;
    cx     = cfg.wwidth / 2;
    margin = 50;

    if strcmp(cfg.handNow, 'left')
        img          = load_png('assets/handL.png');
        instruct_text = 'Please use your left hand for response.';
        img = imresize(img, imgW_pre/size(img,2)/4);
        imgW = size(img, 2);  imgH = size(img, 1);
        imgRect = [cx - imgW - margin, cfg.hheight - imgH - margin, ...
                   cx - margin,        cfg.hheight - margin];
    elseif strcmp(cfg.handNow, 'right')
        img          = load_png('assets/handR.png');
        instruct_text = 'Please use your right hand for response.';
        img = imresize(img, imgW_pre/size(img,2)/4);
        imgW = size(img, 2);  imgH = size(img, 1);
        imgRect = [cx + margin,        cfg.hheight - imgH - margin, ...
                   cx + imgW + margin, cfg.hheight - margin];
    else
        error('instruction_handswitch: cfg.handNow must be ''left'' or ''right''');
    end

    imageTexture = Screen('MakeTexture', window, img);
    DrawFormattedText(window, instruct_text, 'center', 'center', cfg.textColor / 255);
    Screen('DrawTexture', window, imageTexture, [], imgRect);
    if ~isempty(headerText)
        DrawFormattedText(window, headerText, 'center', cfg.hheight * 0.12, cfg.textColor / 255, 90);
    end
    Screen('Flip', window);

    while true
        [~, keyCode] = KbWait(-3, 2);
        temp = KbName(keyCode);

        if ~isempty(temp) && isequal(temp(1), cfg.triggerkey)
            KbReleaseWait(-3);
            break;
        end
    end

    tfun(sprintf('HANDSWITCH_%s', upper(cfg.handNow)));
end
