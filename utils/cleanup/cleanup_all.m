function cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID)
    % Shutdown Eyelink
    Eyelink('SetOfflineMode');
    Eyelink('Command', 'clear_screen 0');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    transfer_file(window, cfg, el, dummymode, edfFile);
    save(fullfile(cfg.logDir, [edfFile '_cfg.mat']), 'cfg'); % Save the cfg struct for later reference
    
    if ~isempty(pahandle)
        PsychPortAudio('Close', pahandle);
    end

    % Close TTL ports
    if dummymode == 0
        ppdev_mex('Close', 1);
    end

    ShowCursor;                            % Show the cursor (it may be hidden during the experiment)
    if ~isempty(logFID) && logFID > 0; fclose(logFID); end   % Close the log file if the file ID is valid
end