function close_logs(logFID, stimLogFID)
if ~isempty(logFID) && logFID > 0
    fclose(logFID);
end
if ~isempty(stimLogFID) && stimLogFID > 0
    fclose(stimLogFID);
end
end