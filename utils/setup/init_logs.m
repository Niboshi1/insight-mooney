function logDir = init_logs(edfFile, taskMode, subsetId, resultsDir)
    % INIT_LOGS  Create a timestamped results directory for this session.
    %
    %   logDir = init_logs(edfFile, taskMode, subsetId, resultsDir)
    %
    % The task log file is opened afterwards with open_log (see run.m).

    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    logDir    = fullfile(resultsDir, ['exp_' timestamp]);
    mkdir(logDir);

    fprintf('Session:    %s\n', edfFile);
    fprintf('Task mode:  %s\n', taskMode);
    fprintf('Subset:     %s\n', subsetId);
    fprintf('Log dir:    %s\n', logDir);
end
