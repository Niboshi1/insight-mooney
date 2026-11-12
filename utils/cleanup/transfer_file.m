% TRANSFER_FILE  Transfer the EDF file from the EyeLink Host PC to the
% Display PC and move it into the session log directory.
function transfer_file(window, cfg, el, dummymode, edfFile)
    try
        if dummymode == 0
            % Show status message while file transfers
            Screen('FillRect', window, el.backgroundcolour);
            Screen('DrawText', window, 'Receiving data file...', 5, cfg.hheight-35, cfg.textColor / 255);
            Screen('Flip', window);
            fprintf('Receiving data file ''%s.edf''\n', edfFile);

            status = Eyelink('ReceiveFile');

            if status > 0
                fprintf('EDF file size: %.1f KB\n', status/1024);
            end

            if exist([edfFile, '.edf'], 'file')
                fprintf('Moving ''%s.edf'' to %s\n', edfFile, cfg.logDir);
                movefile([edfFile, '.edf'], cfg.logDir);
            else
                fprintf('[WARN] EDF file ''%s.edf'' not found in current directory.\n', edfFile);
            end

            fprintf('Data file ''%s.edf'' saved to ''%s''\n', edfFile, cfg.logDir);
        else
            fprintf('[INFO] Dummy mode — no EDF file to transfer.\n');
        end
        cleanup_screen;
    catch
        fprintf('[ERROR] Problem receiving EDF file ''%s.edf''\n', edfFile);
        cleanup_screen;
        psychrethrow(psychlasterror);
    end
end

function cleanup_screen
    sca;
    Eyelink('Shutdown');
    ListenChar(0);
    if ~IsOctave; commandwindow; end
end
