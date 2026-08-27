function phase2_run(numImages, window, mooneyImages, blockStartTime, cfg, tfun, sfun, pahandle, el, dummymode, edfFile, logFID)
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
                    error('Current hand not set in config');
                end
            end
            quitNow = phase2_tutorial(window, mooneyImages{trial}, cfg);

            % Terminate
            if quitNow
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
                    error('Current hand not set in config');
                end
            end

            % Mooney image presentation
            [fixPresentationTime, stimulusPresentationTime, stimEDFTime, responseTime, keyResponse] = phase2_recog( ...
                trial, numImages, window, mooneyImages{trial}, blockStartTime, ...
                cfg, tfun, sfun);

            % Response
            [promptFamiliarTime, keyPressFamiliar, promptRecognitionTime, keyPressRecognition, promptAnswerTime, quitNow] = ...
                phase2_response(trial, window, pahandle, cfg, keyResponse, blockStartTime, tfun, sfun);

            % Terminate
            if quitNow
                return;
            end

            fprintf(logFID, '%d\t%s\t%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t%d\t%.5f\t%d\t%.5f\t%d\n', ...
                trial, cfg.handNow, fixPresentationTime, stimulusPresentationTime, ...
                stimEDFTime, responseTime, promptFamiliarTime, keyPressFamiliar, ...
                promptRecognitionTime, keyPressRecognition, promptAnswerTime, keyResponse);
        end
    end
end
