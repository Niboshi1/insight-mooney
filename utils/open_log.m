function [fid, path] = open_log(cfg, suffix, header)
    % OPEN_LOG  Open <logDir>/<edfFile><suffix> for writing and write a header.
    %
    %   [fid, path] = open_log(cfg, '_a1_log.txt', 'Col1\tCol2\n')
    %
    %   header is a fprintf format string (tab-separated, ending in \n).

    path = fullfile(cfg.logDir, [cfg.edfFile suffix]);
    fid  = fopen(path, 'w');
    if fid < 0
        error('open_log:fail', 'Cannot open log file: %s', path);
    end
    fprintf(fid, header);
end
