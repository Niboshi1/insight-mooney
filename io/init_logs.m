function [logFID, logFileName] = init_logs(edfFile, taskmode)
    if taskmode == 1
        logFileName = [edfFile '_' datestr(now,'yyyymmdd_HHMMSS') '_rec_log.txt'];
        logFID = fopen(logFileName, 'w');
        fprintf(logFID, 'Trial\tFixation_Onset\tStimulus_Onset\tStimulus_Onset_EDF_Time\tResponse_Onset\tPrompt_Answer_Onset\tAnswered\n');
    else
        logFileName = [edfFile '_' datestr(now,'yyyymmdd_HHMMSS') '_mem_log.txt'];
        logFID = fopen(logFileName, 'w');
        fprintf(logFID, 'Trial\tFixation_Onset\tStimulus_Onset\tStimulus_Onset_EDF_Time\tResponse_Onset\tPrompt_Familiar_Onset\tKeyFamiliar\tPrompt_Recognition_Onset\tKeyRecognition\tPrompt_Answer_Onset\tAnswered\n');
    end
end