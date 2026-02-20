package app.snapbeam.photo

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.BitmapFactory
import android.util.Base64
import android.widget.RemoteViews
import android.content.SharedPreferences

/**
 * SnapBeam Widget Provider
 * 
 * Displays the latest shared photo on the home screen widget.
 * Reads data from Flutter's SharedPreferences.
 */
class SnapBeamWidgetProvider : AppWidgetProvider() {
    
    companion object {
        // These keys must match the Flutter shared_preferences keys
        // Flutter's shared_preferences uses "flutter.<key>" format
        private const val KEY_PHOTO = "flutter.last_photo"
        private const val KEY_CAPTION = "flutter.last_caption"
    }
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
    
    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.snapbeam_widget)
        
        // Get data from Flutter's SharedPreferences
        // Flutter's shared_preferences uses the default SharedPreferences
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val photoBase64 = prefs.getString(KEY_PHOTO, null)
        val caption = prefs.getString(KEY_CAPTION, "Waiting for photo...")
        
        // Decode and display photo if available
        if (!photoBase64.isNullOrEmpty()) {
            try {
                val bytes = Base64.decode(photoBase64, Base64.DEFAULT)
                val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                if (bitmap != null) {
                    views.setImageViewBitmap(R.id.widget_image, bitmap)
                } else {
                    views.setImageViewResource(R.id.widget_image, R.drawable.widget_placeholder)
                }
            } catch (e: Exception) {
                views.setImageViewResource(R.id.widget_image, R.drawable.widget_placeholder)
            }
        } else {
            views.setImageViewResource(R.id.widget_image, R.drawable.widget_placeholder)
        }
        
        views.setTextViewText(R.id.widget_caption, caption ?: "Waiting for photo...")
        
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
