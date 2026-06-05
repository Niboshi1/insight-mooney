function [edfFile, taskMode, subsetId] = prompt_info()
    %% Collect session inputs

    taskMode = getNumericInput('Recognition(1) or Memory(2)', 'Task Mode', '1');
    subsetId = getTextInput('Mooney subset (1-5)', 'Subset ID', '1');
    subj     = getTextInput('Enter Subjid', 'Subject ID', '99');
    run      = getTextInput('Enter Run', 'Run Number', '1');

    %% Build EDF filename

    edfFile = sprintf('s%s_r%s', subj, run);

    if strlength(edfFile) > 8
        error('Filename needs to be <= 8 characters (letters, numbers, underscores).');
    end

    %% Local helper functions

    function value = getNumericInput(promptText, dialogTitle, defaultValue)
        response = inputdlg(promptText, dialogTitle, 1, {defaultValue});
        if isempty(response)
            error('Session cancelled by user');
        end

        value = str2double(response{1});
        if isnan(value)
            error('Invalid numeric input for "%s".', promptText);
        end
    end

    function value = getTextInput(promptText, dialogTitle, defaultValue)
        response = inputdlg({promptText}, dialogTitle, 1, {defaultValue});
        if isempty(response)
            error('Session cancelled by user');
        end

        value = response{1};
    end
end