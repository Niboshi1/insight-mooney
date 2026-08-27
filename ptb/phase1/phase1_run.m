function phase1_run(numImages, window, mooneyImages, blockStartTime, cfg, tfun, sfun, pahandle, el, dummymode, edfFile, logFID)
    %% Case 1: Tutorial
    % every step will be controlled by the trigger input from the experiment
    if strcmp(cfg.subsetId, 'tutorial')
        for trial = 1:numImages
            % Hand switch instruction every 2 trials
            if mod(trial, 2) == 1
                instruction_handswitch(window, cfg, tfun);
                if strcmp(cfg.handNow, 'left')
                    cfg.handNow = 'right';
                elseif strcmp(cfg.handNow, 'right')
                    cfg.handNow = 'left';
                else
                    Error('Current hand not set in config');
                end
            end
            quitNow = phase1_tutorial(window, mooneyImages{trial}, cfg);
            
            if quitNow
                cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID);
                return;
            end
        end

    %% Case 2: Run the experiment
    else
        for trial = 1:numImages

            % Hand switch instruction every 5 trials
            if mod(trial, 5) == 1
                instruction_handswitch(window, cfg, tfun);
                if strcmp(cfg.handNow, 'left')
                    cfg.handNow = 'right';
                elseif strcmp(cfg.handNow, 'right')
                    cfg.handNow = 'left';
                else
                    Error('Current hand not set in config');
                end
            end

            % Mooney image prensentation
            [fixPresentationTime, stimulusPresentationTime, stimEDFTime, responseTime, keyResponse] = phase1_recog( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, tfun, sfun);

            % Response
            [promptTime, suddennessRating, suddennessTime, confidenceRating, confidenceTime, quitNow] = ...
                phase1_response(trial, window, pahandle, cfg, keyResponse, blockStartTime, tfun, sfun);

            % Terminate
            if quitNow
                cleanup_all(window, pahandle, cfg, el, dummymode, edfFile, logFID);
                return;
            end

            fprintf(logFID, '%d\t%s\t%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t%d\t%.5f\t%d\t%.5f\t%d\n', ...
                trial, cfg.handNow, fixPresentationTime, stimulusPresentationTime, ...
                stimEDFTime, responseTime, promptTime, keyResponse, ...
                suddennessTime, suddennessRating, confidenceTime, confidenceRating);
        end
    end
end