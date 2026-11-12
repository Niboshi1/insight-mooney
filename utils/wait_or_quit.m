function didQuit = wait_or_quit(duration)
    % WAIT_OR_QUIT  Wait up to 'duration' seconds, polling for a quit key.
    %
    %   didQuit = wait_or_quit(duration)
    %
    %   Returns true immediately if 'q' is pressed; false after full duration.
    %   Polls every 10 ms so latency to detect the keypress is ≤ 10 ms.
    %
    % Call wherever WaitSecs is used during a timing-sensitive hold so the
    % experimenter can abort the task gracefully at any time.

    QUIT_KEY     = 'q';
    POLL_INTERVAL = 0.010;   % 10 ms

    tEnd    = GetSecs + duration;
    didQuit = false;

    while GetSecs < tEnd
        [keyIsDown, ~, keyCode] = KbCheck(-3);
        if keyIsDown
            key = KbName(keyCode);
            if iscell(key); key = key{1}; end
            if ~isempty(key) && key(1) == QUIT_KEY
                KbReleaseWait(-3);
                didQuit = true;
                return;
            end
        end
        WaitSecs(POLL_INTERVAL);
    end
end
