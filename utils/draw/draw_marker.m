function draw_marker(window, cfg, cx, cy, dotOn)
    % DRAW_MARKER  Balanced central marker on the back buffer (no flip).
    %
    %   draw_marker(window, cfg, cx, cy, dotOn)
    %
    % Single-colour cross (both arms cfg.markerColor, 8-bit grey or [R G B]).
    % If dotOn is true a small red dot is drawn at the centre of the cross
    % (attention-check events).  dotOn may be omitted.

    if nargin < 5; dotOn = false; end

    L = cfg.markerArmDeg * cfg.pxPerDeg;
    col = cfg.markerColor(:)' / 255;
    Screen('DrawLines', window, [-L L 0 0; 0 0 -L L], cfg.markerLineW, col', [cx cy], 2);

    if dotOn
        r = cfg.markerDotDeg * cfg.pxPerDeg / 2;
        Screen('FillOval', window, [1 0 0], [cx-r, cy-r, cx+r, cy+r]);
    end
end
