//
// Intensity Minutes Data Field
// Displays per-activity intensity minutes: total, moderate, and vigorous.
//
// HOW IT WORKS:
// The Connect IQ SDK only exposes cumulative (weekly) intensity minute totals.
// There is no direct per-activity intensity minutes field.
// This app snapshots the weekly totals at activity start, then subtracts
// them from the current running total to derive what was earned THIS session.
//

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

//! Main application class
class IntensityMinutesApp extends Application.AppBase {

    //! Constructor
    public function initialize() {
        AppBase.initialize();
    }

    //! Return the initial view for the app
    public function getInitialView() {
        return [new IntensityMinutesView()];
    }
}

//! Application entry point
function getApp() as Application.AppBase {
    return Application.getApp();
}
