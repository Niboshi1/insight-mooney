function cleanup_all(window, logFID)
    try Screen('CloseAll'); catch, end
    try
        Eyelink('Shutdown');
    catch
    end
    ListenChar(0);
    ShowCursor;
    if ~IsOctave; commandwindow; end
    close_logs(logFID);
end