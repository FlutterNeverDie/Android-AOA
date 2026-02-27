package com.example.aoa_tea_time

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbAccessory
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.scspro.aoa/communication"
    private val EVENT_CHANNEL = "com.scspro.aoa/events"
    private val ACTION_USB_PERMISSION = "com.scspro.aoa.USB_PERMISSION"

    private var usbManager: UsbManager? = null
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())

    // 역할별 매니저 클래스
    private var hostHandler: AoaHost? = null
    private var deviceHandler: AoaDevice? = null

    private var currentAppMode = "selection"
    
    // 핸드셰이크 정보 임시 저장
    private var pendingManuf = ""
    private var pendingModel = ""
    private var pendingVer = ""

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
        
        // 매니저 초기화 (MainActivity와 같은 패키지에 있으므로 바로 참조 가능해야 함)
        hostHandler = AoaHost(usbManager!!) { msg -> logToFlutter(msg) }
        deviceHandler = AoaDevice(usbManager!!) { msg -> logToFlutter(msg) }

        // 초기 인텐트 확인
        checkIntent(intent)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAppMode" -> {
                    currentAppMode = call.argument<String>("mode") ?: "selection"
                    logToFlutter("[시스템] 모드 전환: $currentAppMode")
                    result.success(true)
                }
                "checkSupport" -> {
                    result.success(scanForAoaDevices())
                }
                "startAccessory" -> {
                    pendingManuf = call.argument<String>("manufacturer") ?: "SCS PRO"
                    pendingModel = call.argument<String>("model") ?: "NMP-10"
                    pendingVer = call.argument<String>("version") ?: "1.0"
                    requestPermissionForHandshake()
                    result.success(true)
                }
                "setupCommunication" -> {
                    val success = if (currentAppMode == "host") setupHost() else setupDevice()
                    result.success(success)
                }
                "sendMessage" -> {
                    val msg = call.argument<String>("message") ?: ""
                    val success = if (currentAppMode == "host") {
                        hostHandler?.sendMessage(msg) ?: false
                    } else {
                        deviceHandler?.sendMessage(msg) ?: false
                    }
                    result.success(success)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                }
                override fun onCancel(arguments: Any?) { eventSink = null }
            }
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        checkIntent(intent)
    }

    @Suppress("DEPRECATION")
    private fun checkIntent(intent: Intent?) {
        if (intent != null && UsbManager.ACTION_USB_ACCESSORY_ATTACHED == intent.action) {
            val accessory = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(UsbManager.EXTRA_ACCESSORY, UsbAccessory::class.java)
            } else {
                intent.getParcelableExtra(UsbManager.EXTRA_ACCESSORY)
            }
            logToFlutter("[시스템] USB 액세서리 감지됨: ${accessory?.manufacturer}")
        }
    }

    private fun logToFlutter(msg: String) {
        handler.post { eventSink?.success(msg) }
    }

    private fun scanForAoaDevices(): Boolean {
        val deviceList = usbManager?.deviceList
        logToFlutter("[스캔] 장치 ${deviceList?.size ?: 0}개 발견됨")
        deviceList?.values?.forEach { device ->
            logToFlutter("-> VID: 0x${Integer.toHexString(device.vendorId)}, PID: 0x${Integer.toHexString(device.productId)}")
            if (device.vendorId == 0x18D1 && (device.productId == 0x2D00 || device.productId == 0x2D01)) {
                return true
            }
        }
        return false
    }

    private fun requestPermissionForHandshake() {
        val devices = usbManager?.deviceList
        if (devices.isNullOrEmpty()) {
            logToFlutter("[오류] 연결된 USB 장치가 없습니다.")
            return
        }

        // 통상적으로 첫 번째 발견된 일반 안드로이드 기기 타겟
        val target = devices.values.find { it.vendorId != 0x18D1 } ?: devices.values.firstOrNull()
        
        if (target != null) {
            if (usbManager?.hasPermission(target) == true) {
                hostHandler?.doHandshake(target, pendingManuf, pendingModel, pendingVer)
            } else {
                logToFlutter("[안내] 핸드셰이크용 USB 권한 요청...")
                requestUsbPermission(target)
            }
        }
    }

    private fun setupHost(): Boolean {
        val device = usbManager?.deviceList?.values?.find { 
            it.vendorId == 0x18D1 && (it.productId == 0x2D00 || it.productId == 0x2D01) 
        } ?: run {
            logToFlutter("[오류] AOA 모드 장치를 찾을 수 없습니다.")
            return false
        }

        if (usbManager?.hasPermission(device) == true) {
            return hostHandler?.setupCommunication(device) ?: false
        } else {
            logToFlutter("[안내] AOA 통신용 USB 권한 요청...")
            requestUsbPermission(device)
            return false
        }
    }

    private fun setupDevice(): Boolean {
        val accessories = usbManager?.accessoryList
        if (accessories.isNullOrEmpty()) {
            logToFlutter("[오류] 연결된 호스트가 없습니다.")
            return false
        }

        val acc = accessories[0]
        if (usbManager?.hasPermission(acc) == true) {
            return deviceHandler?.setupCommunication(acc) ?: false
        } else {
            logToFlutter("[안내] 액세서리 통신 권한 요청...")
            requestUsbPermission(acc)
            return false
        }
    }

    private fun requestUsbPermission(any: Any) {
        val intent = Intent(ACTION_USB_PERMISSION)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pi = PendingIntent.getBroadcast(this, 0, intent, flags)
        val filter = IntentFilter(ACTION_USB_PERMISSION)
        
        // Android 11 이하는 export 플래그가 필요 없으나 최신 SDK 대응을 위해 조건부 추가 가능
        registerReceiver(usbReceiver, filter)
        
        if (any is UsbDevice) usbManager?.requestPermission(any, pi)
        else if (any is UsbAccessory) usbManager?.requestPermission(any, pi)
    }

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (ACTION_USB_PERMISSION == intent.action) {
                val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                if (granted) {
                    logToFlutter("[성공] USB 권한 승인됨")
                    
                    // 권한 승인 후 자동으로 작업 재개
                    handler.postDelayed({ 
                        if (currentAppMode == "host") {
                            val devices = usbManager?.deviceList
                            // 1. AOA 모드 기기가 이미 있다면 통신 채널 개설 시도
                            val aoaDevice = devices?.values?.find { 
                                it.vendorId == 0x18D1 && (it.productId == 0x2D00 || it.productId == 0x2D01) 
                            }
                            
                            if (aoaDevice != null) {
                                logToFlutter("[자동] 통신 채널 개설을 시작합니다.")
                                setupHost() 
                            } else {
                                // 2. 일반 모드 기기라면 핸드셰이크 시도
                                val target = devices?.values?.find { it.vendorId != 0x18D1 } ?: devices?.values?.firstOrNull()
                                target?.let {
                                    logToFlutter("[자동] 핸드셰이크를 시작합니다.")
                                    hostHandler?.doHandshake(it, pendingManuf, pendingModel, pendingVer)
                                }
                            }
                        } else {
                            // 디바이스 모드인 경우
                            val accessories = usbManager?.accessoryList
                            if (!accessories.isNullOrEmpty()) {
                                logToFlutter("[자동] 통신 채널 연결을 시작합니다.")
                                setupDevice()
                            }
                        }
                    }, 500) // 시스템 처리를 위해 약간의 지연 후 실행
                } else {
                    logToFlutter("[오류] USB 권한 거부됨")
                }
                try { unregisterReceiver(this) } catch (e: Exception) {}
            }
        }
    }

    override fun onDestroy() {
        hostHandler?.close()
        deviceHandler?.close()
        super.onDestroy()
    }
}
