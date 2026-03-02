function memorymode = prompt_memory_mode()
answ = inputdlg('Memory Task?', 'Version', 1, {'1'});
memorymode = str2double(answ);
if isnan(memorymode)
    memorymode = 1;
end
end