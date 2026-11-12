function cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID)
    % CLEANUP_ALL  Orderly shutdown: EyeLink, audio, TTL port, log, PTB window.
    %
    %   cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID)

    %% EyeLink shutdown
    Eyelink('SetOfflineMode');
    Eyelink('Command', 'clear_screen 0');
    WaitSecs(0.5);
    Eyelink('CloseFile');

    %% Transfer EDF and close window
    transfer_file(window, cfg, el, dummymode, edfFile);

    %% Save cfg struct for offline reference
    try
        save(fullfile(cfg.logDir, [edfFile '_cfg.mat']), 'cfg');
    catch saveErr
        fprintf('[WARN] Could not save cfg.mat: %s\n', saveErr.message);
    end

    %% Close audio
    if ~isempty(pahandle)
        PsychPortAudio('Close', pahandle);
    end

    %% Close TTL port
    if dummymode == 0
        try
            ppdev_mex('Close', 1);
        catch
            fprintf('[WARN] Failed to close parallel port.\n');
        end
    end

    ShowCursor;
    if ~isempty(logFID) && logFID > 0; fclose(logFID); end
end
