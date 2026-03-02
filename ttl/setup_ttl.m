function [tfun, sfun] = setup_ttl()

addpath('/home/stimulus/experiments/parallel/ppdev-mex-master');

try
    ppdev_mex('Open', 1);
end

duration = 1000; % in microseconds
address = 1; %hex2dec('3FD8');
code = bin2dec('000000001'); % assumes logging is on cable 1

tfun = @() eyelink_trigger(address, code, duration);

% % duration = .001; % 1 ms
% % address = hex2dec('3FD8');

duration = 1000;
address = 1;
code = bin2dec('000000010'); % assumes stim is on cable 2

sfun = @() stim_function(address, code, duration);

end

function eyelink_trigger(port, code, duration)

lptwrite(port, code, duration);
Eyelink('message','TRIGGER SENT');

end

function stim_function(port, code, duration)

lptwrite(port, code, duration);
% beep;

end