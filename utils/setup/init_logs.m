function [logFID, logDir] = init_logs(edfFile, taskmode, subsetId, resultsDir)
    % Create directory with timestamp in the name
    timestamp = datestr(now,'yyyymmdd_HHMMSS');
    logDir = [resultsDir '/' 'exp_' timestamp];
    mkdir(logDir);

    fprintf('Loading subset: %s\n', subsetId);

    if taskmode == 1
        logFileName = [logDir '/' edfFile '_rec' '_set' subsetId '_log.txt'];
        fprintf('Creating log file: %s\n', logFileName);
        logFID = fopen(logFileName, 'w');
        fprintf(logFID, 'Trial\tFixation_Onset\tStimulus_Onset\tStimulus_Onset_EDF\tPT_Response_Onset\tPrompt_Post_Response\tAnswered\tPrompt_Suddenness\tPT_Suddenness\tPrompt_Confidence\tPT_Confidence\n');

    else
        logFileName = [logDir '/' edfFile '_mem' '_set' subsetId '_log.txt'];
        logFID = fopen(logFileName, 'w');
        fprintf(logFID, 'Trial\tFixation_Onset_GLOB\tStimulus_Onset_GLOB\tStimulus_Onset_EDF_Time\tResponse_Onset\tPrompt_Familiar_Onset\tKeyFamiliar\tPrompt_Recognition_Onset\tKeyRecognition\tPrompt_Answer_Onset\tAnswered\n');
    end
end