function [edfFile, subj, run] = get_edf_name()

prompt = {'Enter Subjid'};
dlg_title = 'Create EDF file';
def = {'99'};
answer = inputdlg(prompt, dlg_title, 1, def);

if isempty(answer)
    error('Session cancelled by user');
end

prompt = {'Enter Run'};
dlg_title = 'Create EDF file';
def = {'1'};
answer2 = inputdlg(prompt, dlg_title, 1, def);

if isempty(answer2)
    error('Session cancelled by user');
end

edfFile = ['s' answer{1} '_r' answer2{1}];

if length(edfFile) > 8
    error('Filename needs to be <= 8 characters (letters, numbers, underscores).');
end

failOpen = Eyelink('OpenFile', edfFile);
if failOpen ~= 0
    error('Cannot create EDF file %s', edfFile);
end

subj = answer{1};
run  = answer2{1};
end