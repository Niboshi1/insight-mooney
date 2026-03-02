function dummymode = check_dummy()
dummymode = 0;
EyelinkInit(dummymode);
status = Eyelink('IsConnected');
if status < 1
    dummymode = 1;
end
end