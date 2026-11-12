addpath(genpath(fileparts(mfilename('fullpath'))));

% Load configuration
cfg = config();
tfun = @(msg) fprintf('[TTL-event] %s\n', msg);

try
    % Init Psychtoolbox
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 1);
    screenNumber = max(Screen('Screens'));
    [window, ~] = PsychImaging('OpenWindow', screenNumber, cfg.itiGray/255);
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    [wwidth, hheight] = Screen('WindowSize', window);
    cfg.wwidth = wwidth; cfg.hheight = hheight; cfg.screenNumber = screenNumber;

    instruction_handswitch(window, cfg, tfun);

    % close
    Screen('CloseAll');

catch ME
    Screen('CloseAll'); % PTB's wrapper for Screen('CloseAll') & related cleanup, e.g. ShowCursor
    ListenChar(0); % Restore keyboard output to Matlab
    rethrow(ME);
end