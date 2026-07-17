package com.example.frontend

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.text.InputFilter
import android.text.InputType
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ArrayAdapter
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.Spinner
import android.widget.TextView
import android.util.Log
import android.util.Base64
import java.net.HttpURLConnection
import java.net.URI
import java.net.URL
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import org.json.JSONObject

class QuickCaptureBubbleService : Service() {
    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var bubbleParams: WindowManager.LayoutParams? = null
    private var panelView: View? = null
    private val networkExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var accessToken: String? = null
    private var accessTokenExpiresAtMs: Long? = null
    private var apiBaseUrl: String? = null
    private var accounts: List<AccountSnapshot> = emptyList()
    private var explicitStop = false

    override fun onCreate() {
        super.onCreate()
        if (isRunning) {
            stopSelf()
            return
        }
        startForeground(NOTIFICATION_ID, buildNotification())
        if (!canDrawOverlays()) {
            setEnabled(false)
            stopSelf()
            return
        }
        restoreConfiguration()
        isRunning = true
        setEnabled(true)
        runCatching { showBubble() }.onFailure {
            setEnabled(false)
            stopSelf()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                explicitStop = true
                setEnabled(false)
                stopSelf()
                return START_NOT_STICKY
            }
            ACTION_SHOW_PANEL -> {
                mainHandler.post { showCapturePanel() }
            }
        }
        if (
            intent?.hasExtra(EXTRA_SESSION_AVAILABLE) == true &&
            !intent.getBooleanExtra(EXTRA_SESSION_AVAILABLE, false)
        ) {
            accessToken = null
            accessTokenExpiresAtMs = null
        }
        intent?.getStringExtra(EXTRA_ACCESS_TOKEN)?.let {
            accessToken = it
            accessTokenExpiresAtMs = parseJwtExpirationMs(it)
        }
        intent?.getStringExtra(EXTRA_API_BASE_URL)?.let { apiBaseUrl = it }
        intent?.getStringExtra(EXTRA_ACCOUNTS_JSON)?.let {
            accounts = parseAccounts(it)
        }
        persistConfiguration()
        logApiHost(apiBaseUrl)
        Log.i(
            TAG,
            "Quick capture snapshot updated: tokenAvailable=${!accessToken.isNullOrBlank()} tokenExpired=${isTokenExpiredOrNearExpiry()}",
        )
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        mainHandler.removeCallbacksAndMessages(null)
        removeView(bubbleView)
        removeView(panelView)
        bubbleView = null
        panelView = null
        bubbleParams = null
        isRunning = false
        if (explicitStop) setEnabled(false)
        networkExecutor.shutdownNow()
        super.onDestroy()
    }

    private fun showBubble() {
        if (bubbleView != null) return
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        val bubble = FrameLayout(this).apply {
            background = GradientDrawable(
                GradientDrawable.Orientation.TL_BR,
                intArrayOf(
                    Color.parseColor("#4F6F52"),
                    Color.parseColor("#2D4F73"),
                ),
            ).apply { cornerRadius = dp(18).toFloat() }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                elevation = dp(8).toFloat()
            }
            contentDescription = "Abrir captura rapida"
        }
        val logo = ImageView(this).apply {
            setImageResource(applicationInfo.icon)
            scaleType = ImageView.ScaleType.CENTER_INSIDE
            setPadding(dp(10), dp(10), dp(10), dp(10))
        }
        bubble.addView(
            logo,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT,
            ),
        )

        val params = overlayParams(
            width = dp(56),
            height = dp(56),
            flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            val position = restoreBubblePosition()
            x = position.first
            y = position.second
        }
        bubble.setOnTouchListener(BubbleTouchListener(params))
        windowManager.addView(bubble, params)
        bubbleView = bubble
        bubbleParams = params
        animateBubbleIn()
    }

    private inner class BubbleTouchListener(
        private val params: WindowManager.LayoutParams,
    ) : View.OnTouchListener {
        private var initialX = 0
        private var initialY = 0
        private var touchX = 0f
        private var touchY = 0f
        private var moved = false

        override fun onTouch(view: View, event: MotionEvent): Boolean {
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    touchX = event.rawX
                    touchY = event.rawY
                    moved = false
                    view.animate().scaleX(0.96f).scaleY(0.96f).setDuration(70)
                        .start()
                    return true
                }

                MotionEvent.ACTION_MOVE -> {
                    val deltaX = (event.rawX - touchX).toInt()
                    val deltaY = (event.rawY - touchY).toInt()
                    if (abs(deltaX) > dp(4) || abs(deltaY) > dp(4)) moved = true
                    val clamped = clampBubblePosition(
                        initialX + deltaX,
                        initialY + deltaY,
                    )
                    params.x = clamped.first
                    params.y = clamped.second
                    bubbleView?.let { windowManager.updateViewLayout(it, params) }
                    return true
                }

                MotionEvent.ACTION_UP,
                MotionEvent.ACTION_CANCEL,
                -> {
                    view.animate().scaleX(1f).scaleY(1f).setDuration(90).start()
                    if (event.action == MotionEvent.ACTION_UP && !moved) {
                        mainHandler.postDelayed({ showCapturePanel() }, 80)
                    } else if (event.action == MotionEvent.ACTION_UP) {
                        snapBubbleToEdge(params)
                    }
                    return true
                }
            }
            return false
        }
    }

    private fun showCapturePanel() {
        if (panelView != null) return
        bubbleView?.visibility = View.INVISIBLE

        var selectedType = "gasto"
        val accountIds = listOf<Long?>(null) + accounts.map { it.id }

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(12), dp(20), dp(20))
            background = roundedBackground("#F6F2E9", 24)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                elevation = dp(14).toFloat()
            }
            alpha = 0f
            translationY = dp(28).toFloat()
        }

        val handle = View(this).apply {
            background = roundedBackground("#C7C4BC", 3)
        }
        container.addView(
            handle,
            LinearLayout.LayoutParams(dp(42), dp(5)).apply {
                gravity = Gravity.CENTER_HORIZONTAL
                bottomMargin = dp(12)
            },
        )
        attachSwipeToClose(handle)

        container.addView(
            TextView(this).apply {
                text = "Captura rapida"
                textSize = 20f
                setTextColor(Color.parseColor("#2E2E2E"))
                setTypeface(typeface, android.graphics.Typeface.BOLD)
            },
            matchWrapParams(),
        )

        val segments = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(dp(3), dp(3), dp(3), dp(3))
            background = outlinedBackground("#F6F2E9", "#D9D4C8", 12)
        }
        val expense = segment("Gasto", true)
        val income = segment("Ingreso", false)
        val transfer = segment("Transferencia", false)
        val allSegments = listOf(expense, income, transfer)
        allSegments.forEach { segments.addView(it, weightedHeightParams(dp(44))) }
        container.addView(segments, matchWrapParams(top = 16))

        val amount = styledInput(
            hint = "Monto",
            inputTypeValue =
                InputType.TYPE_CLASS_NUMBER or
                    InputType.TYPE_NUMBER_FLAG_DECIMAL,
            maxLinesValue = 1,
        )
        container.addView(amount, matchHeightParams(dp(52), top = 12))

        val account = Spinner(this).apply {
            background = outlinedBackground("#FFFFFF", "#D9D4C8", 12)
            setPadding(dp(12), 0, dp(8), 0)
            adapter = accountAdapter(accountLabels("Cuenta (opcional)"))
        }
        container.addView(account, matchHeightParams(dp(52), top = 10))

        val destinationAccount = Spinner(this).apply {
            visibility = View.GONE
            background = outlinedBackground("#FFFFFF", "#D9D4C8", 12)
            setPadding(dp(12), 0, dp(8), 0)
            adapter = accountAdapter(accountLabels("Cuenta destino (opcional)"))
        }
        container.addView(
            destinationAccount,
            matchHeightParams(dp(52), top = 10),
        )

        fun selectType(type: String, selected: TextView) {
            selectedType = type
            allSegments.forEach { styleSegment(it, it === selected) }
            val transferSelected = type == "transferencia"
            destinationAccount.visibility =
                if (transferSelected) View.VISIBLE else View.GONE
            account.adapter = accountAdapter(
                accountLabels(
                    if (transferSelected) {
                        "Cuenta origen (opcional)"
                    } else {
                        "Cuenta (opcional)"
                    },
                ),
            )
        }
        expense.setOnClickListener { selectType("gasto", expense) }
        income.setOnClickListener { selectType("ingreso", income) }
        transfer.setOnClickListener {
            selectType("transferencia", transfer)
        }

        val note = styledInput(
            hint = "Nota rapida (opcional)",
            inputTypeValue =
                InputType.TYPE_CLASS_TEXT or
                    InputType.TYPE_TEXT_FLAG_CAP_SENTENCES,
            maxLinesValue = 2,
        )
        note.filters = arrayOf(InputFilter.LengthFilter(180))
        container.addView(note, matchHeightParams(dp(72), top = 10))

        val feedback = TextView(this).apply {
            visibility = View.GONE
            gravity = Gravity.CENTER
            textSize = 13f
        }
        container.addView(feedback, matchWrapParams(top = 8))

        val continueInApp = TextView(this).apply {
            visibility = View.GONE
            text = "Continuar en CronoFinanzas"
            textSize = 14f
            gravity = Gravity.CENTER
            setTextColor(Color.parseColor("#2D4F73"))
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            background = outlinedBackground("#FFFFFF", "#2D4F73", 12)
            isClickable = true
            isFocusable = true
            setOnClickListener {
                Log.i(TAG, "Direct save fallback: opening app")
                openQuickCapture(
                    type = selectedType,
                    amount = amount.text.toString().trim(),
                    note = note.text.toString().trim(),
                )
            }
        }
        container.addView(continueInApp, matchHeightParams(dp(48), top = 8))

        val saveContent = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            background = roundedBackground("#4F6F52", 12)
            isClickable = true
            isFocusable = true
        }
        val spinner = ProgressBar(this).apply {
            visibility = View.GONE
            indeterminateTintList = android.content.res.ColorStateList.valueOf(
                Color.WHITE,
            )
        }
        val saveLabel = TextView(this).apply {
            text = "Guardar captura"
            textSize = 15f
            setTextColor(Color.WHITE)
            setTypeface(typeface, android.graphics.Typeface.BOLD)
        }
        saveContent.addView(
            spinner,
            LinearLayout.LayoutParams(dp(22), dp(22)).apply {
                marginEnd = dp(8)
            },
        )
        saveContent.addView(saveLabel)
        container.addView(saveContent, matchHeightParams(dp(52), top = 12))

        var saving = false
        saveContent.setOnClickListener {
            if (saving) return@setOnClickListener
            val amountValue = amount.text.toString().trim()
            val parsedAmount = amountValue.replace(',', '.').toDoubleOrNull()
            if (parsedAmount == null || parsedAmount <= 0) {
                showFeedback(feedback, "No se pudo guardar", "#E15D3D")
                amount.background = outlinedBackground(
                    "#FFFFFF",
                    "#E15D3D",
                    12,
                )
                return@setOnClickListener
            }
            amount.background = outlinedBackground("#FFFFFF", "#4F6F52", 12)
            saving = true
            saveContent.isClickable = false
            spinner.visibility = View.VISIBLE
            saveLabel.text = "Guardando..."
            showFeedback(feedback, "Guardando...", "#4F6F52")
            continueInApp.visibility = View.GONE
            saveCaptureDirectly(
                type = selectedType,
                amount = amountValue,
                note = note.text.toString().trim(),
                accountId = accountIds.getOrNull(account.selectedItemPosition),
                destinationAccountId = accountIds.getOrNull(
                    destinationAccount.selectedItemPosition,
                ),
                onSuccess = {
                    spinner.visibility = View.GONE
                    saveLabel.text = "\u2713 Captura guardada"
                    showFeedback(
                        feedback,
                        "\u2713 Captura guardada",
                        "#4F6F52",
                    )
                    mainHandler.postDelayed(
                        { closeCapturePanel(animated = true) },
                        250,
                    )
                },
                onFailure = { state, message ->
                    saving = false
                    saveContent.isClickable = true
                    spinner.visibility = View.GONE
                    saveLabel.text = "Guardar captura"
                    showFeedback(feedback, message, "#E15D3D")
                    continueInApp.visibility =
                        if (state == DirectSaveState.UNAUTHORIZED ||
                            state == DirectSaveState.SESSION_REQUIRED
                        ) {
                            View.VISIBLE
                        } else {
                            View.GONE
                        }
                },
            )
        }

        val params = overlayParams(
            width = resources.displayMetrics.widthPixels - dp(32),
            height = WindowManager.LayoutParams.WRAP_CONTENT,
            flags =
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
        ).apply {
            gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            y = dp(20)
            softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
        }
        container.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_OUTSIDE) {
                closeCapturePanel(animated = true)
                true
            } else {
                false
            }
        }

        runCatching { windowManager.addView(container, params) }
            .onSuccess {
                panelView = container
                container.animate()
                    .alpha(1f)
                    .translationY(0f)
                    .setDuration(170)
                    .start()
            }
            .onFailure {
                bubbleView?.visibility = View.VISIBLE
                animateBubbleIn()
            }
    }

    private fun saveCaptureDirectly(
        type: String,
        amount: String,
        note: String,
        accountId: Long?,
        destinationAccountId: Long?,
        onSuccess: () -> Unit,
        onFailure: (DirectSaveState, String) -> Unit,
    ) {
        val completed = AtomicBoolean(false)
        val timeout = Runnable {
            if (completed.compareAndSet(false, true)) {
                Log.w(TAG, "Direct save fallback: timeout")
                onFailure(
                    DirectSaveState.NETWORK_ERROR,
                    "No se pudo conectar. La captura no fue guardada.",
                )
            }
        }
        mainHandler.postDelayed(timeout, 8_000)
        val token = accessToken
        if (token.isNullOrBlank()) {
            Log.w(TAG, "Direct save fallback: no token")
            if (completed.compareAndSet(false, true)) {
                onFailure(
                    DirectSaveState.SESSION_REQUIRED,
                    "Abre CronoFinanzas una vez para habilitar el guardado.",
                )
            }
            return
        }
        if (isTokenExpiredOrNearExpiry()) {
            Log.w(TAG, "Direct save fallback: token expired=true")
            accessToken = null
            accessTokenExpiresAtMs = null
            if (completed.compareAndSet(false, true)) {
                onFailure(
                    DirectSaveState.UNAUTHORIZED,
                    "Tu sesion necesita actualizarse.",
                )
            }
            return
        }
        val baseUrl = apiBaseUrl
        if (baseUrl.isNullOrBlank()) {
            Log.w(TAG, "Direct save fallback: invalid baseUrl")
            if (completed.compareAndSet(false, true)) {
                onFailure(
                    DirectSaveState.NETWORK_ERROR,
                    "La burbuja no pudo conectarse con CronoFinanzas.",
                )
            }
            return
        }
        val host = runCatching { URI(baseUrl).host }.getOrNull()
        if (host.isNullOrBlank()) {
            Log.w(TAG, "Direct save fallback: invalid baseUrl")
            if (completed.compareAndSet(false, true)) {
                onFailure(
                    DirectSaveState.NETWORK_ERROR,
                    "La burbuja no pudo conectarse con CronoFinanzas.",
                )
            }
            return
        }
        Log.i(TAG, "Direct save API host: $host")
        networkExecutor.execute {
            val result = postCapture(
                baseUrl = baseUrl,
                accessToken = token,
                type = type,
                amount = amount,
                note = note,
                accountId = accountId,
                destinationAccountId = destinationAccountId,
            )
            mainHandler.post {
                if (!completed.compareAndSet(false, true)) return@post
                when (result) {
                    DirectSaveResult.SUCCESS -> {
                        MainActivity.notifyQuickCaptureCreated()
                        onSuccess()
                    }
                    DirectSaveResult.UNAUTHORIZED -> {
                        Log.w(TAG, "Direct save fallback: HTTP 401/403")
                        accessToken = null
                        accessTokenExpiresAtMs = null
                        onFailure(
                            DirectSaveState.UNAUTHORIZED,
                            "Tu sesion necesita actualizarse.",
                        )
                    }
                    DirectSaveResult.FAILURE -> onFailure(
                        DirectSaveState.NETWORK_ERROR,
                        "No se pudo conectar. La captura no fue guardada.",
                    )
                }
            }
        }
    }

    private fun postCapture(
        baseUrl: String,
        accessToken: String,
        type: String,
        amount: String,
        note: String,
        accountId: Long?,
        destinationAccountId: Long?,
    ): DirectSaveResult {
        var connection: HttpURLConnection? = null
        return try {
            val endpoint =
                "${baseUrl.trimEnd('/')}/api/v1/capturas-rapidas/"
            connection = URL(endpoint).openConnection() as HttpURLConnection
            connection.requestMethod = "POST"
            connection.connectTimeout = 3_500
            connection.readTimeout = 3_500
            connection.doOutput = true
            connection.setRequestProperty("Content-Type", "application/json")
            connection.setRequestProperty(
                "Authorization",
                "Bearer $accessToken",
            )
            val payload = JSONObject().apply {
                put("tipo", type)
                put("monto", amount.replace(',', '.').toDouble())
                put("moneda", "PEN")
                if (accountId != null) put("cuenta_id", accountId)
                if (type == "transferencia" && destinationAccountId != null) {
                    put("cuenta_destino_id", destinationAccountId)
                }
                if (note.isNotBlank()) put("nota_rapida", note)
            }
            connection.outputStream.use { stream ->
                stream.write(payload.toString().toByteArray(Charsets.UTF_8))
            }
            val responseCode = connection.responseCode
            when (responseCode) {
                HttpURLConnection.HTTP_CREATED -> DirectSaveResult.SUCCESS
                HttpURLConnection.HTTP_UNAUTHORIZED,
                HttpURLConnection.HTTP_FORBIDDEN,
                -> DirectSaveResult.UNAUTHORIZED
                else -> {
                    Log.w(TAG, "Direct save HTTP error: $responseCode")
                    DirectSaveResult.FAILURE
                }
            }
        } catch (_: Exception) {
            Log.w(TAG, "Direct save fallback: network error")
            DirectSaveResult.FAILURE
        } finally {
            connection?.disconnect()
        }
    }

    private fun closeCapturePanel(animated: Boolean) {
        val panel = panelView ?: return
        panelView = null
        if (animated) {
            panel.animate()
                .alpha(0f)
                .translationY(dp(20).toFloat())
                .setDuration(120)
                .withEndAction {
                    removeView(panel)
                    showBubbleAgain()
                }
                .start()
        } else {
            removeView(panel)
            showBubbleAgain()
        }
    }

    private fun showBubbleAgain() {
        bubbleView?.visibility = View.VISIBLE
        animateBubbleIn()
    }

    private fun animateBubbleIn() {
        bubbleView?.apply {
            alpha = 0f
            scaleX = 0.96f
            scaleY = 0.96f
            animate().alpha(1f).scaleX(1f).scaleY(1f).setDuration(140).start()
        }
    }

    private fun attachSwipeToClose(handle: View) {
        var downY = 0f
        handle.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    downY = event.rawY
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (event.rawY - downY > dp(36)) {
                        closeCapturePanel(animated = true)
                    }
                    true
                }
                else -> true
            }
        }
    }

    private fun openQuickCapture(
        type: String? = null,
        amount: String? = null,
        note: String? = null,
    ) {
        closeCapturePanel(animated = false)
        startActivity(
            Intent(this, MainActivity::class.java).apply {
                putExtra(EXTRA_OPEN_QUICK_CAPTURE, true)
                putExtra(EXTRA_QUICK_CAPTURE_TYPE, type)
                putExtra(EXTRA_QUICK_CAPTURE_AMOUNT, amount)
                putExtra(EXTRA_QUICK_CAPTURE_NOTE, note)
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP,
                )
            },
        )
    }

    private fun segment(label: String, selected: Boolean): TextView {
        return TextView(this).apply {
            text = label
            textSize = 12f
            gravity = Gravity.CENTER
            styleSegment(this, selected)
        }
    }

    private fun styleSegment(view: TextView, selected: Boolean) {
        view.setTextColor(
            if (selected) Color.WHITE else Color.parseColor("#2D4F73"),
        )
        view.background = roundedBackground(
            if (selected) "#4F6F52" else "#F6F2E9",
            10,
        )
    }

    private fun styledInput(
        hint: String,
        inputTypeValue: Int,
        maxLinesValue: Int,
    ): EditText {
        return EditText(this).apply {
            this.hint = hint
            textSize = 15f
            inputType = inputTypeValue
            maxLines = maxLinesValue
            setPadding(dp(14), 0, dp(14), 0)
            setTextColor(Color.parseColor("#2E2E2E"))
            setHintTextColor(Color.parseColor("#77736B"))
            background = outlinedBackground("#FFFFFF", "#D9D4C8", 12)
        }
    }

    private fun accountAdapter(labels: List<String>): ArrayAdapter<String> {
        return ArrayAdapter(
            this,
            android.R.layout.simple_spinner_dropdown_item,
            labels,
        )
    }

    private fun accountLabels(prefix: String): List<String> {
        return listOf("$prefix - Completar luego") +
            accounts.map { "${it.name} (${it.currency})" }
    }

    private fun buildNotification(): Notification {
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (manager.getNotificationChannel(NOTIFICATION_CHANNEL_ID) == null) {
                manager.createNotificationChannel(
                    NotificationChannel(
                        NOTIFICATION_CHANNEL_ID,
                        "Captura rapida",
                        NotificationManager.IMPORTANCE_LOW,
                    ).apply {
                        description =
                            "Mantiene disponible la burbuja de captura rapida"
                        setShowBadge(false)
                        enableVibration(false)
                        setSound(null, null)
                    },
                )
            }
        }
        val openAppIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            openAppIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val stopIntent = PendingIntent.getService(
            this,
            1,
            Intent(this, QuickCaptureBubbleService::class.java).apply {
                action = ACTION_STOP
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val captureIntent = PendingIntent.getService(
            this,
            2,
            Intent(this, QuickCaptureBubbleService::class.java).apply {
                action = ACTION_SHOW_PANEL
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, NOTIFICATION_CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(applicationInfo.icon)
            .setContentTitle("Captura rapida activa")
            .setContentText("Toca para abrir CronoFinanzas.")
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_SERVICE)
            .setShowWhen(false)
            .addAction(applicationInfo.icon, "Capturar", captureIntent)
            .addAction(applicationInfo.icon, "Ocultar burbuja", stopIntent)
            .build()
    }

    private fun restoreConfiguration() {
        val preferences = getSharedPreferences(
            PREFERENCES_NAME,
            Context.MODE_PRIVATE,
        )
        apiBaseUrl = preferences.getString(KEY_API_BASE_URL, null)
        accounts = parseAccounts(
            preferences.getString(KEY_ACCOUNTS_JSON, "[]") ?: "[]",
        )
        logApiHost(apiBaseUrl)
    }

    private fun persistConfiguration() {
        val serializedAccounts = org.json.JSONArray().apply {
            accounts.forEach { account ->
                put(
                    JSONObject().apply {
                        put("id", account.id)
                        put("name", account.name)
                        put("currency", account.currency)
                    },
                )
            }
        }
        getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_API_BASE_URL, apiBaseUrl)
            .putString(KEY_ACCOUNTS_JSON, serializedAccounts.toString())
            .apply()
    }

    private fun restoreBubblePosition(): Pair<Int, Int> {
        val preferences = getSharedPreferences(
            PREFERENCES_NAME,
            Context.MODE_PRIVATE,
        )
        val defaultX = resources.displayMetrics.widthPixels - dp(76)
        val defaultY = dp(180)
        return clampBubblePosition(
            preferences.getInt(KEY_BUBBLE_X, defaultX),
            preferences.getInt(KEY_BUBBLE_Y, defaultY),
        )
    }

    private fun persistBubblePosition(x: Int, y: Int) {
        getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            .edit()
            .putInt(KEY_BUBBLE_X, x)
            .putInt(KEY_BUBBLE_Y, y)
            .apply()
    }

    private fun clampBubblePosition(x: Int, y: Int): Pair<Int, Int> {
        val metrics = resources.displayMetrics
        val maxX = max(0, metrics.widthPixels - dp(56))
        val maxY = max(0, metrics.heightPixels - dp(112))
        return Pair(
            min(max(0, x), maxX),
            min(max(dp(24), y), maxY),
        )
    }

    private fun snapBubbleToEdge(params: WindowManager.LayoutParams) {
        val metrics = resources.displayMetrics
        val targetX = if (params.x + dp(28) < metrics.widthPixels / 2) {
            dp(8)
        } else {
            max(0, metrics.widthPixels - dp(64))
        }
        val clamped = clampBubblePosition(targetX, params.y)
        params.x = clamped.first
        params.y = clamped.second
        bubbleView?.let { windowManager.updateViewLayout(it, params) }
        persistBubblePosition(params.x, params.y)
    }

    private fun parseAccounts(raw: String): List<AccountSnapshot> {
        return runCatching {
            val array = org.json.JSONArray(raw)
            buildList {
                for (index in 0 until array.length()) {
                    val item = array.optJSONObject(index) ?: continue
                    val id = item.optLong("id", -1)
                    val name = item.optString("name")
                    val currency = item.optString("currency", "PEN")
                    if (id > 0 && name.isNotBlank()) {
                        add(AccountSnapshot(id, name, currency))
                    }
                }
            }
        }.getOrDefault(emptyList())
    }

    private fun logApiHost(baseUrl: String?) {
        val host = baseUrl
            ?.takeIf { it.isNotBlank() }
            ?.let { runCatching { URI(it).host }.getOrNull() }
        if (host.isNullOrBlank()) {
            Log.w(TAG, "Quick capture API host unavailable")
        } else {
            Log.i(TAG, "Quick capture API host: $host")
        }
    }

    private fun parseJwtExpirationMs(token: String): Long? {
        return runCatching {
            val parts = token.split(".")
            if (parts.size < 2) return@runCatching null
            val payload = String(
                Base64.decode(
                    parts[1],
                    Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING,
                ),
                Charsets.UTF_8,
            )
            val expSeconds = JSONObject(payload).optLong("exp", 0)
            if (expSeconds <= 0) null else expSeconds * 1_000
        }.getOrNull()
    }

    private fun isTokenExpiredOrNearExpiry(): Boolean {
        val expiresAt = accessTokenExpiresAtMs ?: return false
        return expiresAt - System.currentTimeMillis() <= TOKEN_EXPIRY_GRACE_MS
    }

    private fun showFeedback(view: TextView, message: String, color: String) {
        view.text = message
        view.setTextColor(Color.parseColor(color))
        view.visibility = View.VISIBLE
    }

    private fun roundedBackground(color: String, radius: Int): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(radius).toFloat()
            setColor(Color.parseColor(color))
        }
    }

    private fun outlinedBackground(
        fill: String,
        stroke: String,
        radius: Int,
    ): GradientDrawable {
        return roundedBackground(fill, radius).apply {
            setStroke(dp(1), Color.parseColor(stroke))
        }
    }

    private fun overlayParams(
        width: Int,
        height: Int,
        flags: Int,
    ): WindowManager.LayoutParams {
        return WindowManager.LayoutParams(
            width,
            height,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            },
            flags,
            PixelFormat.TRANSLUCENT,
        )
    }

    private fun matchWrapParams(top: Int = 0): LinearLayout.LayoutParams {
        return LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.WRAP_CONTENT,
        ).apply { topMargin = dp(top) }
    }

    private fun matchHeightParams(
        height: Int,
        top: Int = 0,
    ): LinearLayout.LayoutParams {
        return LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            height,
        ).apply { topMargin = dp(top) }
    }

    private fun weightedHeightParams(height: Int): LinearLayout.LayoutParams {
        return LinearLayout.LayoutParams(0, height, 1f).apply {
            marginStart = dp(2)
            marginEnd = dp(2)
        }
    }

    private fun removeView(view: View?) {
        if (view != null && ::windowManager.isInitialized) {
            runCatching { windowManager.removeView(view) }
        }
    }

    private fun canDrawOverlays(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            Settings.canDrawOverlays(this)
    }

    private fun setEnabled(enabled: Boolean) {
        getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_BUBBLE_ENABLED, enabled)
            .apply()
    }

    private fun dp(value: Int): Int {
        return (value * resources.displayMetrics.density).toInt()
    }

    private enum class DirectSaveResult {
        SUCCESS,
        UNAUTHORIZED,
        FAILURE,
    }

    private enum class DirectSaveState {
        SESSION_REQUIRED,
        UNAUTHORIZED,
        NETWORK_ERROR,
    }

    private data class AccountSnapshot(
        val id: Long,
        val name: String,
        val currency: String,
    )

    companion object {
        const val EXTRA_OPEN_QUICK_CAPTURE = "open_quick_capture"
        const val EXTRA_QUICK_CAPTURE_TYPE = "quick_capture_tipo"
        const val EXTRA_QUICK_CAPTURE_AMOUNT = "quick_capture_monto"
        const val EXTRA_QUICK_CAPTURE_NOTE = "quick_capture_nota"
        const val PREFERENCES_NAME = "quick_capture_preferences"
        const val KEY_BUBBLE_ENABLED = "bubble_enabled"
        const val EXTRA_ACCESS_TOKEN = "quick_capture_access_token"
        const val EXTRA_SESSION_AVAILABLE = "quick_capture_session_available"
        const val EXTRA_API_BASE_URL = "quick_capture_api_base_url"
        const val EXTRA_ACCOUNTS_JSON = "quick_capture_accounts_json"
        const val ACTION_START_OR_UPDATE =
            "com.example.frontend.quick_capture.START_OR_UPDATE"
        const val ACTION_STOP =
            "com.example.frontend.quick_capture.STOP"
        const val ACTION_SHOW_PANEL =
            "com.example.frontend.quick_capture.SHOW_PANEL"
        const val KEY_RESTORE_ON_BOOT = "restore_on_boot"
        const val KEY_API_BASE_URL = "api_base_url"
        const val KEY_ACCOUNTS_JSON = "accounts_json"
        private const val KEY_BUBBLE_X = "bubble_x"
        private const val KEY_BUBBLE_Y = "bubble_y"
        private const val NOTIFICATION_CHANNEL_ID =
            "quick_capture_service"
        private const val NOTIFICATION_ID = 2401
        private const val TOKEN_EXPIRY_GRACE_MS = 30_000L
        private const val TAG = "QuickCapture"

        @Volatile
        var isRunning: Boolean = false
            private set
    }
}
