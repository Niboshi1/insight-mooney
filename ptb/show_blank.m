function show_blank(window, grayValue, eyelinkMsg)
    Screen('FillRect', window, grayValue);
    Screen('Flip', window);
    if nargin >= 3 && ~isempty(eyelinkMsg)
        Eyelink('Message', eyelinkMsg);
    end
end