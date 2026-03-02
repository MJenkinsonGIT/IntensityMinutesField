//
// Intensity Minutes Data Field View
//
// Layout:
//   [Intensity Mins label]
//   [Total value - large, centered]
//   [Mod: X (left)]  [Vig: X (right)]
//
// Data source strategy:
//   - SDK provides only CUMULATIVE weekly totals (ActivityMonitor.activeMinutesWeek)
//   - We snapshot baseline values at onTimerStart()
//   - Per-activity = current weekly total - baseline
//   - Vigorous minutes count double toward the total per WHO guidelines,
//     so the total displayed is: moderate + (vigorous * 2), matching Garmin's
//     native "Intensity Minutes" field behavior.
//

import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Main data field view class
class IntensityMinutesView extends WatchUi.DataField {

    // Baseline weekly values captured when activity timer starts
    private var _baselineModerate as Number;
    private var _baselineVigorous as Number;
    private var _timerStarted as Boolean;

    // Display values (computed each cycle)
    private var _totalMins as Number;
    private var _moderateMins as Number;
    private var _vigorousMins as Number;

    // Layout positions (calculated once in onLayout)
    private var _xCenter as Number;
    private var _yTotal as Number;
    private var _yLabel as Number;
    private var _yBottom as Number;
    private var _xLeft as Number;
    private var _xRight as Number;

    //! Constructor
    public function initialize() {
        DataField.initialize();

        _baselineModerate = 0;
        _baselineVigorous = 0;
        _timerStarted = false;

        _totalMins = 0;
        _moderateMins = 0;
        _vigorousMins = 0;

        _xCenter = 0;
        _yTotal = 0;
        _yLabel = 0;
        _yBottom = 0;
        _xLeft = 0;
        _xRight = 0;
    }

    //! Called once when layout dimensions are known
    public function onLayout(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        _xCenter = width / 2;
        _xLeft = (width * 3) / 20;
        _xRight = (width * 17) / 20;

        // Three vertical zones:
        // Top: "Intensity Mins" label
        // Middle: total value (large)
        // Bottom: moderate and vigorous side by side
        _yLabel = height / 6;
        _yTotal = (height * 11) / 20;
        _yBottom = (height * 3) / 4;
    }

    //! Called when the activity timer starts - capture baseline
    public function onTimerStart() as Void {
        var info = ActivityMonitor.getInfo();
        if (info != null && (info has :activeMinutesWeek) && info.activeMinutesWeek != null) {
            var weekly = info.activeMinutesWeek;
            if (weekly.moderate != null) {
                _baselineModerate = weekly.moderate;
            }
            if (weekly.vigorous != null) {
                _baselineVigorous = weekly.vigorous;
            }
        }
        _timerStarted = true;
    }

    //! Called when activity timer resets (e.g. discard activity)
    public function onTimerReset() as Void {
        _baselineModerate = 0;
        _baselineVigorous = 0;
        _timerStarted = false;
        _totalMins = 0;
        _moderateMins = 0;
        _vigorousMins = 0;
    }

    //! Called periodically to update data calculations
    public function compute(info as Activity.Info) as Void {
        // If the timer hasn't started yet, keep showing zeros
        // (Don't try to compute before we have a baseline)
        if (!_timerStarted) {
            _totalMins = 0;
            _moderateMins = 0;
            _vigorousMins = 0;
            return;
        }

        var amInfo = ActivityMonitor.getInfo();
        if (amInfo == null || !(amInfo has :activeMinutesWeek) || amInfo.activeMinutesWeek == null) {
            return;
        }

        var weekly = amInfo.activeMinutesWeek;

        // Get current cumulative totals, default to baseline if null
        var currentMod = (weekly.moderate != null) ? weekly.moderate : _baselineModerate;
        var currentVig = (weekly.vigorous != null) ? weekly.vigorous : _baselineVigorous;

        // Activity-session deltas (clamp to 0 to handle edge cases)
        var sessionMod = currentMod - _baselineModerate;
        var sessionVig = currentVig - _baselineVigorous;

        if (sessionMod < 0) { sessionMod = 0; }
        if (sessionVig < 0) { sessionVig = 0; }

        _moderateMins = sessionMod;
        _vigorousMins = sessionVig;

        // Per WHO / Garmin convention: vigorous counts double toward total.
        // total = moderate + (vigorous * 2)
        _totalMins = sessionMod + (sessionVig * 2);
    }

    //! Called to render the data field
    public function onUpdate(dc as Dc) as Void {
        // Determine colors based on theme
        var bgColor = getBackgroundColor();
        var fgColor = Graphics.COLOR_WHITE;
        if (bgColor == Graphics.COLOR_WHITE) {
            fgColor = Graphics.COLOR_BLACK;
        }

        // Clear background
        dc.setColor(fgColor, bgColor);
        dc.clear();
        dc.setColor(fgColor, Graphics.COLOR_TRANSPARENT);

        // --- Top label: "Intensity Mins" ---
        dc.drawText(
            _xCenter,
            _yLabel,
            Graphics.FONT_XTINY,
            "Intensity Mins",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // --- Middle: Total value (large) ---
        dc.drawText(
            _xCenter,
            _yTotal,
            Graphics.FONT_NUMBER_MEDIUM,
            _totalMins.format("%d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // --- Bottom row: Moderate (left) and Vigorous (right) ---
        // Labels on top of values
        var bottomLabelY = _yBottom - 28;

        // Moderate label and value
        dc.drawText(
            _xLeft,
            bottomLabelY,
            Graphics.FONT_XTINY,
            "Mod",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            _xLeft,
            _yBottom,
            Graphics.FONT_SMALL,
            _moderateMins.format("%d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Vigorous label and value
        dc.drawText(
            _xRight,
            bottomLabelY,
            Graphics.FONT_XTINY,
            "Vig",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            _xRight,
            _yBottom,
            Graphics.FONT_SMALL,
            _vigorousMins.format("%d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // (No dividing line)
    }
}
