package app.snapbeam.photo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Boot Receiver
 * 
 * Restarts widget updates after device reboot.
 * The widget updates are handled by the system's updatePeriodMillis setting.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.intent.action.BOOT_COMPLETED") {
            // Widget will auto-update based on updatePeriodMillis in widget_info.xml
            // No additional action needed
        }
    }
}
