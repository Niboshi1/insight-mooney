function show_instruction(window, taskmode, triggerkey, tfun)
    if taskmode == 1
        instruct_text = ['You will see a series of Black and White images.\n\n' ...
                        'As soon as you think you know what the picture is,\n\n' ...
                        'press a key (1).'];
    else
        instruct_text = ['You will see a series of Black and White images.\n\n' ...
                        'After each image, answer the question on the screen.\n\n'];
    end

    DrawFormattedText(window, instruct_text, 'center', 'center', .2);
    Screen('Flip', window);

    while true
        [~, keyCode] = KbWait(-3, 2);
        temp = KbName(keyCode);

        if isempty(triggerkey) || isequal(temp(1), triggerkey)
            break;
        end
    end

    if ~strcmp(tfun, 'NA')
        feval(tfun);
    end
end