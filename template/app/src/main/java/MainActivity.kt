package __APP_ID__

import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.widget.TextView
import androidx.activity.ComponentActivity

const val TAG = "__LOG_TAG__"

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // deploy.cmd follows this tag (kit.properties' logTags).
        Log.i(TAG, "started")
        setContentView(
            TextView(this).apply {
                text = getString(R.string.app_name)
                textSize = 24f
                gravity = Gravity.CENTER
            },
        )
    }
}
