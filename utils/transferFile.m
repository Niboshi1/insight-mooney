% Function for transferring copy of EDF file to the experiment folder on Display PC.
% Allows for optional destination path which is different from experiment folder
function transferFile(window, cfg, el, dummymode, edfFile)
    try
        if dummymode ==0 % If connected to EyeLink
            % Show 'Receiving data file...' text until file transfer is complete
            Screen('FillRect', window, el.backgroundcolour); % Prepare background on backbuffer
            Screen('DrawText', window, 'Receiving data file...', 5, cfg.hheight-35, 0); % Prepare text
            Screen('Flip', window); % Present text
            fprintf('Receiving data file ''%s.edf''\n', edfFile); % Print some text in Matlab's Command Window
            
            % Transfer EDF file to Host PC
            % [status =] Eyelink('ReceiveFile',['src'], ['dest'], ['dest_is_path'])
            status = Eyelink('ReceiveFile');
            
            % Check if EDF file has been transferred successfully and print file size in Matlab's Command Window
            if status > 0
                fprintf('EDF file size: %.1f KB\n', status/1024); % Divide file size by 1024 to convert bytes to KB
            end

            % Move the EDF file to the experiment folder
            movefile(edfFile, cfg.logDir);

            % Print transferred EDF file path in Matlab's Command Window
            fprintf('Data file ''%s.edf'' can be found in ''%s''\n', edfFile, cfg.logDir);
        else
            fprintf('No EDF file saved in Dummy mode\n');
        end
        cleanup;
    catch % Catch a file-transfer error and print some text in Matlab's Command Window
        fprintf('Problem receiving data file ''%s''\n', edfFile);
        cleanup;
        psychrethrow(psychlasterror);
    end
end

function cleanup
    sca; % PTB's wrapper for Screen('CloseAll') & related cleanup, e.g. ShowCursor
    Eyelink('Shutdown'); % Close EyeLink connection
    ListenChar(0); % Restore keyboard output to Matlab
    if ~IsOctave; commandwindow; end % Bring Command Window to front
end