function h = volshow_rgb_dualAlpha(V, opts)
%VOLSHOW_RGB_DUALALPHA
% Render an RGB volume with separate Red/Green/Blue alpha controls and optional overlay controls.
%
% INPUT
%   V: X-by-Y-by-Z-by-3 numeric volume (RGB). Zeros render black.
%
% UI
%   - Uses classic uicontrol sliders (works in normal figures used by viewer3d/volshow).
%   - Panel is docked near the top-left.
%   - Panel width/height are locked to the initial figure size (no resizing with figure).
%   - Columns left->right: RED | GREEN | BLUE | OVERLAY
%   - Rows top->bottom: Low, High, Exp, Gain
%       * Channel Gain (R/G/B): if Gain = 0, that channel is completely hidden.
%       * Overlay Gain exists only if OverlayData is provided.
%
% Overlay
%   opts.OverlayData:
%       []             : no overlay
%       X-by-Y-by-Z    : scalar overlay intensity, colorized by opts.OverlayColor
%       X-by-Y-by-Z-by-3 : RGB overlay volume
%   Overlay alpha is controlled separately and composited into both color + alpha.

arguments
    V {mustBeNumeric, mustBeNonempty}
    opts.Parent = []
    opts.BackgroundColor (1,1) string = "white"
    opts.BackgroundGradient (1,1) string = "off"

    opts.RedScale   (1,2) double = [NaN NaN]
    opts.GreenScale (1,2) double = [NaN NaN]
    opts.BlueScale  (1,2) double = [NaN NaN]

    opts.CombineMode (1,1) string {mustBeMember(opts.CombineMode,["union","max"])} = "union"
    opts.ZeroAlpha (1,1) double {mustBeNonnegative, mustBeLessThanOrEqual(opts.ZeroAlpha,1)} = 0.001
    opts.ClampAlpha (1,1) logical = true

    % Overlay
    opts.OverlayData = []
    opts.OverlayScale (1,2) double = [NaN NaN]
    opts.OverlayColor (1,3) double {mustBeGreaterThanOrEqual(opts.OverlayColor,0),mustBeLessThanOrEqual(opts.OverlayColor,1)} = [1 0 1]

    % UI
    opts.UI (1,1) logical = true

    % Panel sizing (locked to initial figure)
    opts.PanelWidthFrac  (1,1) double {mustBeGreaterThan(opts.PanelWidthFrac,0), mustBeLessThan(opts.PanelWidthFrac,0.99)} = 0.96
    opts.PanelMinPixelsW (1,1) double {mustBePositive} = 820
    opts.PanelMarginPx   (1,1) double {mustBeNonnegative} = 8
    opts.PanelPadPx      (1,1) double {mustBeNonnegative} = 8
    opts.BottomSlackPx   (1,1) double {mustBeNonnegative} = 10

    % UI geometry (pixels)
    opts.LabelWidthPx    (1,1) double {mustBePositive} = 34
    opts.SliderWidthPx   (1,1) double {mustBePositive} = 120
    opts.ValueWidthPx    (1,1) double {mustBePositive} = 46
    opts.ColSpacingPx    (1,1) double {mustBeNonnegative} = 18
    opts.RowSpacingPx    (1,1) double {mustBeNonnegative} = 6
    opts.HeaderHeightPx  (1,1) double {mustBePositive} = 22
    opts.RowHeightPx     (1,1) double {mustBePositive} = 22

    % Title bar estimate (platform-dependent; used only for panel height calculation)
    opts.TitleBarPx      (1,1) double {mustBeNonnegative} = 26
end

% --- Validate V
if ndims(V) ~= 4 || size(V,4) ~= 3
    error("V must be X-by-Y-by-Z-by-3 (RGB). Got size: %s", mat2str(size(V)));
end

% --- viewer3d (white background)
if isempty(opts.Parent) || ~isvalid(opts.Parent)
    vw = viewer3d(BackgroundColor=opts.BackgroundColor, BackgroundGradient=opts.BackgroundGradient);
else
    vw = opts.Parent;
    try
        vw.BackgroundColor = opts.BackgroundColor;
        vw.BackgroundGradient = opts.BackgroundGradient;
    catch
    end
end

% --- Normalize base RGB to [0,1]
Vr0 = normalize01(V(:,:,:,1), opts.RedScale);
Vg0 = normalize01(V(:,:,:,2), opts.GreenScale);
Vb0 = normalize01(V(:,:,:,3), opts.BlueScale);

% --- State (transfer function params + gain)
state = struct();
state.rLow=0.02; state.rHigh=0.25; state.rExp=1.0; state.rGain=1.0;
state.gLow=0.02; state.gHigh=0.25; state.gExp=1.0; state.gGain=1.0;
state.bLow=0.02; state.bHigh=0.25; state.bExp=1.0; state.bGain=1.0;

state.oLow=0.05; state.oHigh=0.50; state.oExp=1.0; state.oGain=0.60;

% --- Overlay parse
hasOverlay = ~isempty(opts.OverlayData);
if hasOverlay
    [Orgb, Oi] = parseOverlay(opts.OverlayData, opts.OverlayScale, opts.OverlayColor, [size(Vr0,1) size(Vr0,2) size(Vr0,3) 3]);
else
    Orgb = []; Oi = [];
end

% --- Compose & render
[dispRGB, A] = composeAll(Vr0, Vg0, Vb0, state, opts, hasOverlay, Orgb, Oi);
volObj = volshow(dispRGB, Parent=vw, AlphaData=A);

h = struct("viewer",vw,"vol",volObj,"state",state);

% =====================================================================
% UI (classic uicontrols so it works in regular figure)
% =====================================================================

% Predeclare resize-locked panel state for nested onResize
fig = [];
pnl = [];
panelW0 = [];
panelH0 = [];
margin = [];

% Geometry cached for addRowUI
labelW  = opts.LabelWidthPx;
sliderW = opts.SliderWidthPx;
valueW  = opts.ValueWidthPx;
rowH    = opts.RowHeightPx;

if opts.UI
    fig = ancestor(vw, "figure");
    if isempty(fig) || ~isvalid(fig), fig = gcf; end

    pnl = uipanel(fig, ...
        "Title","Alpha controls (R/G/B + optional Overlay)", ...
        "Units","pixels");

    % ===== Lock panel size ONCE (initial figure size) =====
    fp0 = fig.Position;
    margin = opts.PanelMarginPx;

    colW = labelW + sliderW + valueW;
    neededW = 2*opts.PanelPadPx + 4*colW + 3*opts.ColSpacingPx; % R,G,B,O

    panelW0 = max(opts.PanelMinPixelsW, round(opts.PanelWidthFrac * fp0(3)));
    panelW0 = max(panelW0, neededW);
    panelW0 = min(panelW0, fp0(3) - 2*margin);

    % Rows (Low/High/Exp/Gain) for channels; overlay also 4 if present.
    nCtrlRowsMax = 4;

    ctrlH    = nCtrlRowsMax*opts.RowHeightPx + (nCtrlRowsMax-1)*opts.RowSpacingPx;
    contentH = opts.HeaderHeightPx + ctrlH;
    panelH0  = opts.TitleBarPx + 2*opts.PanelPadPx + contentH + opts.BottomSlackPx;
    panelH0  = min(panelH0, fp0(4) - 2*margin);

    pnl.Position = [margin, fp0(4) - margin - panelH0, panelW0, panelH0];

    % Re-dock only (no resize). NOTE: width and height never change.
    fig.SizeChangedFcn = @onResize;

    % ===== Pixel layout within panel =====
    pad   = opts.PanelPadPx;
    colSp = opts.ColSpacingPx;
    rowSp = opts.RowSpacingPx;
    headerH = opts.HeaderHeightPx;

    % Panel-local coordinates (origin bottom-left)
    yTop = panelH0 - pad - opts.TitleBarPx; % approx location under title bar

    % Column x origins: Red | Green | Blue | Overlay
    xR = pad;
    xG = xR + colW + colSp;
    xB = xG + colW + colSp;
    xO = xB + colW + colSp;

    % Header y
    yHeader = yTop - headerH;

    % Rows y (top->bottom)
    yLow  = yHeader - rowSp - rowH;
    yHigh = yLow    - rowSp - rowH;
    yExp  = yHigh   - rowSp - rowH;
    yGain = yExp    - rowSp - rowH;

    bg = get(pnl,"BackgroundColor");

    % Column headers
    uicontrol(pnl,"Style","text","String","Red","Units","pixels", ...
        "Position",[xR, yHeader, colW, headerH], ...
        "HorizontalAlignment","left","FontWeight","bold","BackgroundColor",bg);
    uicontrol(pnl,"Style","text","String","Green","Units","pixels", ...
        "Position",[xG, yHeader, colW, headerH], ...
        "HorizontalAlignment","left","FontWeight","bold","BackgroundColor",bg);
    uicontrol(pnl,"Style","text","String","Blue","Units","pixels", ...
        "Position",[xB, yHeader, colW, headerH], ...
        "HorizontalAlignment","left","FontWeight","bold","BackgroundColor",bg);
    uicontrol(pnl,"Style","text","String", tern(hasOverlay,"Overlay","Overlay (none)"),"Units","pixels", ...
        "Position",[xO, yHeader, colW, headerH], ...
        "HorizontalAlignment","left","FontWeight","bold","BackgroundColor",bg);

    % Red controls
    [s_rLow,  v_rLow ] = addRowUI(pnl, xR, yLow,  "Low",  0,   0.20, state.rLow,  @(v)setField("rLow",v));
    [s_rHigh, v_rHigh] = addRowUI(pnl, xR, yHigh, "High", 0,   1.00, state.rHigh, @(v)setField("rHigh",v));
    [s_rExp,  v_rExp ] = addRowUI(pnl, xR, yExp,  "Exp",  0.2, 5.00, state.rExp,  @(v)setField("rExp",v));
    [s_rGain, v_rGain] = addRowUI(pnl, xR, yGain, "Gain", 0,   2.00, state.rGain, @(v)setField("rGain",v));

    % Green controls
    [s_gLow,  v_gLow ] = addRowUI(pnl, xG, yLow,  "Low",  0,   0.20, state.gLow,  @(v)setField("gLow",v));
    [s_gHigh, v_gHigh] = addRowUI(pnl, xG, yHigh, "High", 0,   1.00, state.gHigh, @(v)setField("gHigh",v));
    [s_gExp,  v_gExp ] = addRowUI(pnl, xG, yExp,  "Exp",  0.2, 5.00, state.gExp,  @(v)setField("gExp",v));
    [s_gGain, v_gGain] = addRowUI(pnl, xG, yGain, "Gain", 0,   2.00, state.gGain, @(v)setField("gGain",v));

    % Blue controls (inserted between Green and Overlay)
    [s_bLow,  v_bLow ] = addRowUI(pnl, xB, yLow,  "Low",  0,   0.20, state.bLow,  @(v)setField("bLow",v));
    [s_bHigh, v_bHigh] = addRowUI(pnl, xB, yHigh, "High", 0,   1.00, state.bHigh, @(v)setField("bHigh",v));
    [s_bExp,  v_bExp ] = addRowUI(pnl, xB, yExp,  "Exp",  0.2, 5.00, state.bExp,  @(v)setField("bExp",v));
    [s_bGain, v_bGain] = addRowUI(pnl, xB, yGain, "Gain", 0,   2.00, state.bGain, @(v)setField("bGain",v));

    % Overlay controls (only if hasOverlay)
    if hasOverlay
        [s_oLow,  v_oLow ] = addRowUI(pnl, xO, yLow,  "Low",  0,   0.50, state.oLow,  @(v)setField("oLow",v));
        [s_oHigh, v_oHigh] = addRowUI(pnl, xO, yHigh, "High", 0,   1.00, state.oHigh, @(v)setField("oHigh",v));
        [s_oExp,  v_oExp ] = addRowUI(pnl, xO, yExp,  "Exp",  0.2, 5.00, state.oExp,  @(v)setField("oExp",v));
        [s_oGain, v_oGain] = addRowUI(pnl, xO, yGain, "Gain", 0,   1.00, state.oGain, @(v)setField("oGain",v));
    else
        [s_oLow,s_oHigh,s_oExp,s_oGain] = deal([]);
        [v_oLow,v_oHigh,v_oExp,v_oGain] = deal([]);
    end

    % Store UI handles for setField
    h.uiPanel = pnl;
    h.ui = struct( ...
        "s_rLow",s_rLow,"s_rHigh",s_rHigh,"s_rExp",s_rExp,"s_rGain",s_rGain, ...
        "s_gLow",s_gLow,"s_gHigh",s_gHigh,"s_gExp",s_gExp,"s_gGain",s_gGain, ...
        "s_bLow",s_bLow,"s_bHigh",s_bHigh,"s_bExp",s_bExp,"s_bGain",s_bGain, ...
        "s_oLow",s_oLow,"s_oHigh",s_oHigh,"s_oExp",s_oExp,"s_oGain",s_oGain, ...
        "v_rLow",v_rLow,"v_rHigh",v_rHigh,"v_rExp",v_rExp,"v_rGain",v_rGain, ...
        "v_gLow",v_gLow,"v_gHigh",v_gHigh,"v_gExp",v_gExp,"v_gGain",v_gGain, ...
        "v_bLow",v_bLow,"v_bHigh",v_bHigh,"v_bExp",v_bExp,"v_bGain",v_bGain, ...
        "v_oLow",v_oLow,"v_oHigh",v_oHigh,"v_oExp",v_oExp,"v_oGain",v_oGain );
end

% =========================== nested callbacks ===========================

function onResize(~,~)
    % Keep panel fixed size; only re-dock position (no width/height scaling).
    if isempty(fig) || isempty(pnl) || ~isvalid(fig) || ~isvalid(pnl)
        return;
    end
    fp = fig.Position;
    x = margin;
    y = fp(4) - margin - panelH0;
    pnl.Position = [x, y, panelW0, panelH0];
end

function [sld, valTxt] = addRowUI(parent, x, y, name, mn, mx, val, cb)
    bgLocal = get(parent,"BackgroundColor");

    uicontrol(parent,"Style","text","String",name,"Units","pixels", ...
        "Position",[x, y, labelW, rowH], ...
        "HorizontalAlignment","left","BackgroundColor",bgLocal);

    sld = uicontrol(parent,"Style","slider","Units","pixels", ...
        "Min",mn,"Max",mx,"Value",val, ...
        "Position",[x+labelW, y+4, sliderW, rowH-8], ...
        "Callback",@(src,~) cb(get(src,"Value")));

    valTxt = uicontrol(parent,"Style","text","String",num2str(val,"%.3g"),"Units","pixels", ...
        "Position",[x+labelW+sliderW, y, valueW, rowH], ...
        "HorizontalAlignment","left","BackgroundColor",bgLocal);
end

function out = tern(cond, a, b)
    if cond, out = a; else, out = b; end
end

function setField(fname, val)
    state.(fname) = val;

    % enforce low<=high
    state.rLow = min(state.rLow, state.rHigh);
    state.gLow = min(state.gLow, state.gHigh);
    state.bLow = min(state.bLow, state.bHigh);
    state.oLow = min(state.oLow, state.oHigh);

    % clamp gains (avoid negatives)
    state.rGain = max(0, state.rGain);
    state.gGain = max(0, state.gGain);
    state.bGain = max(0, state.bGain);
    state.oGain = max(0, min(1, state.oGain));

    % push corrected values to sliders
    pushIfValid(h.ui.s_rLow, state.rLow);  pushIfValid(h.ui.s_rHigh, state.rHigh);
    pushIfValid(h.ui.s_gLow, state.gLow);  pushIfValid(h.ui.s_gHigh, state.gHigh);
    pushIfValid(h.ui.s_bLow, state.bLow);  pushIfValid(h.ui.s_bHigh, state.bHigh);
    pushIfValid(h.ui.s_oLow, state.oLow);  pushIfValid(h.ui.s_oHigh, state.oHigh);

    % update readouts (uicontrol text uses "String")
    safeSet(h.ui.v_rLow, state.rLow);   safeSet(h.ui.v_rHigh, state.rHigh); safeSet(h.ui.v_rExp, state.rExp);   safeSet(h.ui.v_rGain, state.rGain);
    safeSet(h.ui.v_gLow, state.gLow);   safeSet(h.ui.v_gHigh, state.gHigh); safeSet(h.ui.v_gExp, state.gExp);   safeSet(h.ui.v_gGain, state.gGain);
    safeSet(h.ui.v_bLow, state.bLow);   safeSet(h.ui.v_bHigh, state.bHigh); safeSet(h.ui.v_bExp, state.bExp);   safeSet(h.ui.v_bGain, state.bGain);
    safeSet(h.ui.v_oLow, state.oLow);   safeSet(h.ui.v_oHigh, state.oHigh); safeSet(h.ui.v_oExp, state.oExp);   safeSet(h.ui.v_oGain, state.oGain);

    [dispRGBnew, Anew] = composeAll(Vr0, Vg0, Vb0, state, opts, hasOverlay, Orgb, Oi);
    try
        volObj.Data      = dispRGBnew;
        volObj.AlphaData = Anew;
    catch ME
        warning("Could not update volshow properties: %s", ME.message);
    end
    h.state = state;
end

% =========================== UI helpers ===========================

function pushIfValid(s, v)
    if ~isempty(s) && isvalid(s)
        try, set(s, "Value", v); catch, end
    end
end

function safeSet(lbl, v)
    if ~isempty(lbl) && isvalid(lbl)
        try, set(lbl, "String", num2str(v,"%.3g")); catch, end
    end
end

% =========================== rendering helpers ===========================

function Xn = normalize01(X, scale)
    X = single(X);
    if any(isnan(scale))
        x = X(:); x = x(isfinite(x));
        lo = 0;
        if isempty(x)
            hi = 1;
        else
            hi = prctile(double(x), 99.5);
            if hi <= lo, hi = lo + 1; end
        end
    else
        lo = single(scale(1)); hi = single(scale(2));
        if hi <= lo, hi = lo + 1; end
    end
    Xn = (X - lo) ./ (hi - lo);
    Xn = max(0, min(1, Xn));
    Xn(X == 0) = 0;
end

function a = tfAlpha(I, low, high, expo, zeroAlpha)
    den = max(high - low, eps('single'));
    t = (I - low) ./ den;
    t = max(0, min(1, t));
    a = t .^ single(expo);
    a(I == 0) = single(zeroAlpha);
    a = max(single(zeroAlpha), a);
end

function Abase = computeBaseAlpha(Vr_, Vg_, Vb_, state_, opts_)
    % Per-channel alpha TF + gain (gain==0 => no contribution)
    aR = tfAlpha(Vr_, state_.rLow, state_.rHigh, state_.rExp, opts_.ZeroAlpha) .* single(state_.rGain);
    aG = tfAlpha(Vg_, state_.gLow, state_.gHigh, state_.gExp, opts_.ZeroAlpha) .* single(state_.gGain);
    aB = tfAlpha(Vb_, state_.bLow, state_.bHigh, state_.bExp, opts_.ZeroAlpha) .* single(state_.bGain);

    aR = max(0, min(1, aR));
    aG = max(0, min(1, aG));
    aB = max(0, min(1, aB));

    switch opts_.CombineMode
        case "union"
            Abase = 1 - (1 - aR).*(1 - aG).*(1 - aB);
        case "max"
            Abase = max(aR, max(aG, aB));
    end

    % If all channels are exactly zero, make alpha minimal
    allZero = (Vr_ == 0) & (Vg_ == 0) & (Vb_ == 0);
    Abase(allZero) = min(Abase(allZero), opts_.ZeroAlpha);

    if opts_.ClampAlpha
        Abase = max(0, min(1, Abase));
    end
    Abase = single(Abase);
end

function [Orgb_, Oi_] = parseOverlay(OverlayData, overlayScale, overlayColor, baseSize)
    sx = baseSize(1); sy = baseSize(2); sz = baseSize(3);
    od = OverlayData;

    if ndims(od)==3
        if ~isequal(size(od), [sx sy sz])
            error("OverlayData (scalar) must match V size. Got %s", mat2str(size(od)));
        end
        Oi_ = normalize01(od, overlayScale);
        Or = overlayColor(1) * ones(sx,sy,sz,'single');
        Og = overlayColor(2) * ones(sx,sy,sz,'single');
        Ob = overlayColor(3) * ones(sx,sy,sz,'single');
        Orgb_ = cat(4, Or, Og, Ob);

    elseif ndims(od)==4 && size(od,4)==3
        if ~isequal(size(od,1),sx) || ~isequal(size(od,2),sy) || ~isequal(size(od,3),sz)
            error("OverlayData (RGB) must match V size. Got %s", mat2str(size(od)));
        end
        Or = normalize01(od(:,:,:,1), [NaN NaN]);
        Og = normalize01(od(:,:,:,2), [NaN NaN]);
        Ob = normalize01(od(:,:,:,3), [NaN NaN]);
        Orgb_ = cat(4, Or, Og, Ob);
        Oi_ = max(Orgb_, [], 4);

    else
        error("OverlayData must be [] or X-by-Y-by-Z or X-by-Y-by-Z-by-3.");
    end
end

function [dispRGB_, A_] = composeAll(Vr_, Vg_, Vb_, state_, opts_, hasOverlay_, Orgb_, Oi_)
    % Apply color gains to channels (gain==0 => channel hidden)
    VrDisp = max(0, min(1, Vr_ .* single(state_.rGain)));
    VgDisp = max(0, min(1, Vg_ .* single(state_.gGain)));
    VbDisp = max(0, min(1, Vb_ .* single(state_.bGain)));

    VrgbDisp = cat(4, VrDisp, VgDisp, VbDisp);
    Abase = computeBaseAlpha(Vr_, Vg_, Vb_, state_, opts_);

    if ~hasOverlay_
        dispRGB_ = VrgbDisp;
        A_ = Abase;
        return;
    end

    Ao = tfAlpha(Oi_, state_.oLow, state_.oHigh, state_.oExp, opts_.ZeroAlpha);
    Ao = single(state_.oGain) .* Ao;
    Ao = max(0, min(1, Ao));

    dispRGB_ = (1 - Ao).*VrgbDisp + Ao.*Orgb_;
    A_ = 1 - (1 - Abase).*(1 - Ao);

    if opts_.ClampAlpha
        A_ = max(0, min(1, A_));
    end
    A_ = single(A_);
end

end