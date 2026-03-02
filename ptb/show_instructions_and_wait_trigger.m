function show_instructions_and_wait_trigger(window, memorymode, triggerkey, tfun)

if memorymode == 1
    instruct_text = ['You will see a series of images.\n\n' ...
                     'After each image, press a key if:\n\n' ...
                     'it is New (1), you are Unsure (2), or it is Old (3).'];
else
    instruct_text = ['You will see a series of images.\n\n' ...
                     'After each image, press a key if:\n\n' ...
                     'you Like (1) the image, you are Unsure (2), or you Dislike (3).'];
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