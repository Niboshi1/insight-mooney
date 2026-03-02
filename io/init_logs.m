function [logFID, stimLogFID, logFileName, stimLogFileName] = init_logs(edfFile)

logFileName = [edfFile '_experiment_log.txt'];
logFID = fopen(logFileName, 'w');
fprintf(logFID, 'Trial\tStimulus_Onset\tFixation_Onset\tResponse_Onset\tResponse\tRT\tCondition\n');

stimLogFileName = [edfFile '_stim_log.txt'];
stimLogFID = fopen(stimLogFileName, 'w');
fprintf(stimLogFID, 'Trial\tStimulus_Onset\tCondition\n');
end