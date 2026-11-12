function quit = wait_until(tAbs)
    % WAIT_UNTIL  Poll for 'q' until absolute time tAbs (GetSecs clock).
    %
    %   quit = wait_until(tAbs)   % true if 'q' was pressed

    quit = false;
    while GetSecs < tAbs
        [down, ~, kc] = KbCheck(-3);
        if down
            key = KbName(kc);
            if iscell(key); key = key{1}; end
            if ~isempty(key) && key(1) == 'q'
                KbReleaseWait(-3);
                quit = true;
                return;
            end
        end
        WaitSecs(0.005);
    end
end
