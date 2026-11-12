function [edfFile, taskMode, subsetId, tutorial, subj, runNum] = prompt_info()
    % PROMPT_INFO  Collect session metadata via GUI dialogs.
    %
    %   [edfFile, taskMode, subsetId, tutorial, subj, runNum] = prompt_info()
    %
    %   taskMode  – 'phase1' (recognition) | 'phase2' (memory)
    %   subsetId  – Mooney subset '1'-'5', or 'tutorial'
    %   edfFile   – EyeLink filename (s<subj>_r<run>, max 8 characters)

    taskList = {'phase1  —  Recognition (insight) task', ...
                'phase2  —  Memory task'};
    [sel, ok] = listdlg( ...
        'ListString',   taskList, ...
        'SelectionMode','single', ...
        'Name',         'Task Selection', ...
        'PromptString', 'Select task to run:', ...
        'OKString',     'Run', ...
        'ListSize',     [380 100]);
    if ~ok || isempty(sel)
        error('prompt_info:cancelled', 'Session cancelled by user.');
    end
    taskKeys = {'phase1', 'phase2'};
    taskMode = taskKeys{sel};

    answer = questdlg('Is this a tutorial session?', 'Tutorial', 'Yes', 'No', 'No');
    if isempty(answer); error('prompt_info:cancelled', 'Session cancelled by user.'); end
    tutorial = strcmp(answer, 'Yes');
    if tutorial
        subsetId = 'tutorial';
    else
        subsetId = getTextInput('Mooney subset (1-5)', 'Subset ID', '1');
    end

    subj   = getTextInput('Subject ID', 'Subject ID', '99');
    runNum = getTextInput('Run number', 'Run Number', '1');

    edfFile = sprintf('s%s_r%s', subj, runNum);
    if strlength(edfFile) > 8
        error('prompt_info:edfTooLong', ...
            'EDF filename ''%s'' exceeds 8 characters (required by EyeLink).', edfFile);
    end

    fprintf('\n--- Session info ---\n');
    fprintf('Subject:   %s\n', subj);
    fprintf('Run:       %s\n', runNum);
    fprintf('Task:      %s\n', taskMode);
    fprintf('Subset:    %s\n', subsetId);
    fprintf('EDF file:  %s\n', edfFile);
    fprintf('--------------------\n\n');

    %% Local helper -------------------------------------------------------
    function value = getTextInput(promptText, dialogTitle, defaultValue)
        response = inputdlg({promptText}, dialogTitle, 1, {defaultValue});
        if isempty(response)
            error('prompt_info:cancelled', 'Session cancelled by user.');
        end
        value = strtrim(response{1});
    end
end
