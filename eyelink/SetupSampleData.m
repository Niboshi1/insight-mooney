function SetupSampleData(edfFile, dummymode)

ELsoftwareVersion = 0;
[ver, versionstring] = Eyelink('GetTrackerVersion');

if dummymode == 0
    [~, vnumcell] = regexp(versionstring,'.*?(\d)\.\d*?','Match','Tokens');
    ELsoftwareVersion = str2double(vnumcell{1}{1});
    fprintf('Running experiment on %s version %d\n', versionstring, ver);
end

preambleText = sprintf('RECORDED BY Psychtoolbox demo %s session name: %s', mfilename, edfFile);
Eyelink('Command', 'add_file_preamble_text "%s"', preambleText);

Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,FIXUPDATE,INPUT');

if ELsoftwareVersion > 3
    Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,HTARGET,GAZERES,BUTTON,STATUS,INPUT');
    Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
else
    Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,GAZERES,BUTTON,STATUS,INPUT');
    Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
end

end