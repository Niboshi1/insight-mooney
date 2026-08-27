function instruction_init(window, taskmode, triggerkey, tfun, tutorial)
    if taskmode == 1
        instruct_text = ['You will see a series of Black and White images.\n\n' ...
                        'As soon as you think you know what the picture is, press "1" key.\n\n' ...
                        'After each image, answer the question on the screen.'];
    else
        instruct_text =['You will see a series of Black and White images.\n\n' ...
                        'As soon as you think you know what the picture is, press "1" key.\n\n' ...
                        'After each image, answer the question on the screen.'];
    end

    DrawFormattedText(window, instruct_text, 'center', 'center', .2);

    if tutorial
        [~, hheight] = Screen('WindowSize', window);
        DrawFormattedText2('<size=30>This is tutorial', 'win', window, ...
            'sx', 'center', 'sy', hheight + 10, ...
            'xalign', 'center', 'baseColor', [1 0 0]);
    end

    Screen('Flip', window);

    while true
        [~, keyCode] = KbWait(-3, 2);
        temp = KbName(keyCode);

        if ~isempty(temp) && isequal(temp(1), triggerkey)
            break;
        end
    end

    if ~strcmp(tfun, 'NA')
        feval(tfun);
    end
end