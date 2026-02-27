package com.example.aoa_tea_time

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.*
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.scspro.aoa/communication"
    private val EVENT_CHANNEL = "com.scspro.aoa/events"
    private val ACTION_USB_PERMISSION = "com.scspro.aoa.USB_PERMISSION"

    private var usbManager: UsbManager? = null
    private var eventSink: EventChannel.EventSink? = null
    
    // For Host Mode
    private var usbDevice: UsbDevice? = null
    private var hostConnection: UsbDeviceConnection? = null
    private var endpointIn: UsbEndpoint? = null
    private var endpointOut: UsbEndpoint? = null

    // For Device Mode
    private var accessory: UsbAccessory? = null
    private var fileDescriptor: ParcelFileDescriptor? = null
    private var inputStream: FileInputStream? = null
    private var outputStream: FileOutputStream? = null

    private var currentAppMode = "selection"
    
    // 권한 요청 시 전달할 정보 임시 저장
    private var pendingManuf = ""
    private var pendingModel = ""
    private var pendingVer = ""

    private val handler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager

        if (intent.action == UsbManager.ACTION_USB_ACCESSORY_ATTACHED) {
            accessory = intent.getParcelableExtra(UsbManager.EXTRA_ACCESSORY)
            logToFlutter("[시스템] USB 액세서리 연결로 앱이 실행되었습니다.")
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAppMode" -> {
                    currentAppMode = call.argument<String>("mode") ?: "selection"
                    logToFlutter("[시스템] 앱 모드: ${if(currentAppMode == "host") "호스트" else "디바이스"}")
                    result.success(true)
                }
                "checkSupport" -> {
                    val supported = scanForDevices()
                    result.success(supported)
                }
                "startAccessory" -> {
                    pendingManuf = call.argument<String>("manufacturer") ?: "SCS PRO"
                    pendingModel = call.argument<String>("model") ?: "NMP-10"
                    pendingVer = call.argument<String>("version") ?: "1.0"
                    startAoaHandshake(pendingManuf, pendingModel, pendingVer)
                    result.success(true)
                }
                "setupCommunication" -> {
                    val success = if (currentAppMode == "host") setupHostCommunication() else setupDeviceCommunication()
                    result.success(success)
                }
                "sendMessage" -> {
                    val msg = call.argument<String>("message") ?: ""
                    val success = if (currentAppMode == "host") sendHostMessage(msg) else sendDeviceMessage(msg)
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
        if (intent.action == UsbManager.ACTION_USB_ACCESSORY_ATTACHED) {
            accessory = intent.getParcelableExtra(UsbManager.EXTRA_ACCESSORY)
            logToFlutter("[시스템] 새로운 액세서리 연결을 감지했습니다.")
        }
    }

    private fun logToFlutter(msg: String) {
        handler.post { eventSink?.success(msg) }
    }

    private fun scanForDevices(): Boolean {
        val devices = usbManager?.deviceList
        logToFlutter("[스캔] 장치 ${devices?.size ?: 0}개 발견됨")
        devices?.values?.forEach { device ->
            logToFlutter("-> VID: 0x${Integer.toHexString(device.vendorId)}, PID: 0x${Integer.toHexString(device.productId)}")
            if (device.vendorId == 0x18D1 && (device.productId == 0x2D00 || device.productId == 0x2D01)) {
                return true
            }
        }
        return false
    }

    private fun startAoaHandshake(manuf: String, model: String, ver: String) {
        val devices = usbManager?.deviceList
        if (devices.isNullOrEmpty()) {
            logToFlutter("[오류] 연결된 USB 장치가 없습니다.")
            return
        }

        val target = devices.values.first()
        if (usbManager?.hasPermission(target) == true) {
            doHandshake(target, manuf, model, ver)
        } else {
            logToFlutter("[안내] USB 권한을 요청합니다. 팝업 확인 부탁드립니다.")
            
            // Android 11(30) 이상에서는 FLAG_MUTABLE이 권장되거나 필요합니다.
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            // 권한 요청을 위한 PendingIntent 생성 및 BroadcastReceiver 등록
            val pi = PendingIntent.getBroadcast(this, 0, Intent(ACTION_USB_PERMISSION), flags)
            registerReceiver(usbReceiver, IntentFilter(ACTION_USB_PERMISSION))
            usbManager?.requestPermission(target, pi)
        }
    }

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (ACTION_USB_PERMISSION == intent.action) {
                val device: UsbDevice? = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                    logToFlutter("[성공] USB 권한 승인됨")
                    device?.let { doHandshake(it, pendingManuf, pendingModel, pendingVer) }
                } else {
                    logToFlutter("[오류] USB 권한이 거부되었습니다.")
                }
                unregisterReceiver(this)
            }
        }
    }

    private fun doHandshake(device: UsbDevice, manuf: String, model: String, ver: String) {
        val conn = usbManager?.openDevice(device) ?: run {
            logToFlutter("[오류] 장치를 열 수 없습니다.")
            return
        }
        logToFlutter("[명령] AOA 핸드셰이크 시퀀스 시작...")
        
        // 공백이나 특수문자 실수를 방지하기 위해 trim() 처리
        val m = manuf.trim()
        val mo = model.trim()
        val v = ver.trim()

        val proto = ByteArray(2)
        conn.controlTransfer(0xC0, 51, 0, 0, proto, 2, 1000)
        
        val sendStr = { idx: Int, s: String ->
            // AOA 프로토콜 사양에 따라 문자열은 반드시 null-terminated (\u0000)여야 합니다.
            val nullTerminatedString = s + "\u0000"
            val b = nullTerminatedString.toByteArray(StandardCharsets.UTF_8)
            conn.controlTransfer(0x40, 52, 0, idx, b, b.size, 1000)
        }
        
        sendStr(0, m)
        sendStr(1, mo)
        sendStr(2, "AOA 티타임")
        sendStr(3, v)
        
        logToFlutter("[명령] START 신호 전송")
        conn.controlTransfer(0x40, 53, 0, 0, null, 0, 1000)
        conn.close()
    }

        val targetDevice = devices?.values?.find { 
            it.vendorId == 0x18D1 && (it.productId == 0x2D00 || it.productId == 0x2D01) 
        } ?: run {
            logToFlutter("[오류] 통신 가능한 AOA 장치를 찾을 수 없습니다. (핸드셰이크 확인 요망)")
            return false
        }

        if (!usbManager!!.hasPermission(targetDevice)) {
            logToFlutter("[안내] AOA 모드 장치(0x${Integer.toHexString(targetDevice.productId)})에 대한 권한이 필요합니다. 팝업을 확인해주세요.")
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pi = PendingIntent.getBroadcast(this, 0, Intent(ACTION_USB_PERMISSION), flags)
            registerReceiver(usbReceiver, IntentFilter(ACTION_USB_PERMISSION))
            usbManager?.requestPermission(targetDevice, pi)
            return false
        }

        val conn = usbManager?.openDevice(targetDevice) ?: run {
            logToFlutter("[오류] AOA 장치를 열 수 없습니다.")
            return false
        }
        hostConnection = conn

        // AOA 표준 사양: SET_CONFIGURATION(0x09) 요청을 통해 구성을 1로 설정
        logToFlutter("[시스템] 기기 구성(Configuration) 활성화 중...")
        val setConfigResult = conn.controlTransfer(0x00, 0x09, 1, 0, null, 0, 2000)
        logToFlutter("[시스템] 구성 활성화 결과: $setConfigResult")

        // 첫 번째 인터페이스 점유 (PID 0x2D01의 경우 표준 통신용)
        val iface = accessory.getInterface(0)
        val claimed = conn.claimInterface(iface, true)
        if (!claimed) {
            logToFlutter("[오류] 인터페이스 점유 실패")
            return false
        }

        for (i in 0 until iface.endpointCount) {
            val ep = iface.getEndpoint(i)
            if (ep.type == UsbConstants.USB_ENDPOINT_XFER_BULK) {
                if (ep.direction == UsbConstants.USB_DIR_IN) endpointIn = ep
                else endpointOut = ep
            }
        }

        if (endpointIn == null || endpointOut == null) {
            logToFlutter("[오류] 엔드포인트를 찾을 수 없습니다.")
            return false
        }

        Thread {
            val buf = ByteArray(1024)
            try {
                while (hostConnection != null) {
                    val len = hostConnection?.bulkTransfer(endpointIn, buf, buf.size, 500) ?: -1
                    if (len > 0) logToFlutter("수신됨: ${String(buf, 0, len, StandardCharsets.UTF_8)}")
                }
            } catch (e: Exception) {
                logToFlutter("[안내] 호스트 수신 중단: ${e.message}")
            }
        }.start()

        logToFlutter("[성공] 호스트 통신 준비 완료")
        return true
    }

    private fun sendHostMessage(msg: String): Boolean {
        val b = msg.toByteArray()
        return (hostConnection?.bulkTransfer(endpointOut, b, b.size, 1000) ?: -1) >= 0
    }

    private fun setupDeviceCommunication(): Boolean {
        val accessories = usbManager?.accessoryList
        if (accessories.isNullOrEmpty()) {
            logToFlutter("[오류] 호스트 액세서리를 찾을 수 없습니다.")
            return false
        }

        val acc = accessories[0]
        accessory = acc
        
        fileDescriptor = usbManager?.openAccessory(acc)
        if (fileDescriptor == null) {
            logToFlutter("[오류] 액세서리 열기 실패 (권한 요망)")
            return false
        }

        val fd = fileDescriptor?.fileDescriptor ?: return false
        inputStream = FileInputStream(fd)
        outputStream = FileOutputStream(fd)

        Thread {
            val buf = ByteArray(1024)
            try {
                while (inputStream != null) {
                    val len = inputStream?.read(buf) ?: -1
                    if (len > 0) logToFlutter("수신됨: ${String(buf, 0, len)}")
                }
            } catch (e: Exception) {
                logToFlutter("[안내] 수신 중단: ${e.message}")
            }
        }.start()

        logToFlutter("[성공] 디바이스 통신 준비 완료")
        return true
    }

    private fun sendDeviceMessage(msg: String): Boolean {
        return try {
            outputStream?.write(msg.toByteArray())
            true
        } catch (e: Exception) { false }
    }
}
