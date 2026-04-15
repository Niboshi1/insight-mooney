function cleanup_all(window, cfg, el, dummymode, edfFile, logFID)
    % Shutdown Eyelink
    Eyelink('SetOfflineMode');
    Eyelink('Command', 'clear_screen 0');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    transferFile(window, cfg, el, dummymode, edfFile);
    ShowCursor;                            % Show the cursor (it may be hidden during the experiment)
    if ~isempty(logFID) && logFID > 0; fclose(logFID); end   % Close the log file if the file ID is valid
end