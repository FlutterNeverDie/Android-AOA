package com.example.aoa_tea_time

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.*
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

    private val handler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager

        // Check if we were launched by a USB accessory
        if (intent.action == UsbManager.ACTION_USB_ACCESSORY_ATTACHED) {
            accessory = intent.getParcelableExtra(UsbManager.EXTRA_ACCESSORY)
            logToFlutter("[시스템] USB 액세서리 연결로 앱이 실행되었습니다.")
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAppMode" -> {
                    currentAppMode = call.argument<String>("mode") ?: "selection"
                    logToFlutter("[시스템] 앱 모드가 '${if(currentAppMode == "host") "호스트" else "디바이스"}'로 설정되었습니다.")
                    result.success(true)
                }
                "checkSupport" -> {
                    val supported = scanForDevices()
                    result.success(supported)
                }
                "startAccessory" -> {
                    val manuf = call.argument<String>("manufacturer") ?: "SCS PRO"
                    val model = call.argument<String>("model") ?: "NMP-10"
                    val ver = call.argument<String>("version") ?: "1.0"
                    startAoaHandshake(manuf, model, ver)
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
                    logToFlutter("[시스템] 네이티브 시스템이 준비되었습니다.")
                }
                override fun onCancel(arguments: Any?) { eventSink = null }
            }
        )
    }

    private fun logToFlutter(msg: String) {
        handler.post { eventSink?.success(msg) }
    }

    // --- HOST MODE LOGIC ---
    private fun scanForDevices(): Boolean {
        val devices = usbManager?.deviceList
        logToFlutter("[스캔] 총 ${devices?.size ?: 0}개의 USB 장치 발견")
        devices?.values?.forEach { device ->
            logToFlutter("[장치] VID=0x${Integer.toHexString(device.vendorId)}, PID=0x${Integer.toHexString(device.productId)}")
            if (device.vendorId == 0x18D1 && (device.productId == 0x2D00 || device.productId == 0x2D01)) {
                logToFlutter("[안내] 액세서리 모드의 장치를 찾았습니다.")
                return true
            }
        }
        return false
    }

    private fun startAoaHandshake(manuf: String, model: String, ver: String) {
        val devices = usbManager?.deviceList
        if (devices.isNullOrEmpty()) {
            logToFlutter("[오류] AOA를 시작할 장치를 찾을 수 없습니다.")
            return
        }

        val target = devices.values.first()
        if (usbManager?.hasPermission(target) == true) {
            doHandshake(target, manuf, model, ver)
        } else {
            logToFlutter("[시스템] USB 권한을 요청합니다...")
            val pi = PendingIntent.getBroadcast(this, 0, Intent(ACTION_USB_PERMISSION), PendingIntent.FLAG_IMMUTABLE)
            registerReceiver(usbReceiver, IntentFilter(ACTION_USB_PERMISSION))
            usbManager?.requestPermission(target, pi)
        }
    }

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (ACTION_USB_PERMISSION == intent.action) {
                val device: UsbDevice? = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                    logToFlutter("[시스템] USB 권한이 승인되었습니다.")
                    device?.let { doHandshake(it, "SCS PRO", "NMP-10", "1.0") }
                } else {
                    logToFlutter("[오류] USB 권한이 거부되었습니다.")
                }
                unregisterReceiver(this)
            }
        }
    }

    private fun doHandshake(device: UsbDevice, manuf: String, model: String, ver: String) {
        val conn = usbManager?.openDevice(device) ?: return
        logToFlutter("[핸드셰이크] ${device.deviceName} 장치와 연결 시도 중...")
        
        val proto = ByteArray(2)
        conn.controlTransfer(0xC0, 51, 0, 0, proto, 2, 1000)
        
        val sendStr = { idx: Int, s: String ->
            val b = s.toByteArray()
            conn.controlTransfer(0x40, 52, 0, idx, b, b.size, 1000)
        }
        
        sendStr(0, manuf)
        sendStr(1, model)
        sendStr(2, "AOA 티타임 액세서리")
        sendStr(3, ver)
        
        logToFlutter("[명령] START(시작) 신호를 보냅니다.")
        conn.controlTransfer(0x40, 53, 0, 0, null, 0, 1000)
        conn.close()
    }

    private fun setupHostCommunication(): Boolean {
        val devices = usbManager?.deviceList
        val accessory = devices?.values?.find { 
            it.vendorId == 0x18D1 && (it.productId == 0x2D00 || it.productId == 0x2D01) 
        } ?: run {
            logToFlutter("[오류] 액세서리 모드의 장치를 찾을 수 없습니다. (먼저 시작 시도를 해주세요)")
            return false
        }

        val conn = usbManager?.openDevice(accessory) ?: return false
        hostConnection = conn
        val iface = accessory.getInterface(0)
        conn.claimInterface(iface, true)

        for (i in 0 until iface.endpointCount) {
            val ep = iface.getEndpoint(i)
            if (ep.type == UsbConstants.USB_ENDPOINT_XFER_BULK) {
                if (ep.direction == UsbConstants.USB_DIR_IN) endpointIn = ep
                else endpointOut = ep
            }
        }

        Thread {
            val buf = ByteArray(1024)
            while (hostConnection != null) {
                val len = hostConnection?.bulkTransfer(endpointIn, buf, buf.size, 0) ?: -1
                if (len > 0) logToFlutter("수신됨: ${String(buf, 0, len)}")
            }
        }.start()

        logToFlutter("[시스템] 호스트 통신 채널이 준비되었습니다.")
        return true
    }

    private fun sendHostMessage(msg: String): Boolean {
        val b = msg.toByteArray()
        return (hostConnection?.bulkTransfer(endpointOut, b, b.size, 1000) ?: -1) >= 0
    }

    // --- DEVICE MODE LOGIC ---
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
            logToFlutter("[오류] 액세서리를 열 수 없습니다. (권한 부족 또는 연결 끊김)")
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
                logToFlutter("[오류] 수신 스트림이 닫혔습니다: ${e.message}")
            }
        }.start()

        logToFlutter("[시스템] 디바이스 통신 채널이 활성화되었습니다.")
        return true
    }

    private fun sendDeviceMessage(msg: String): Boolean {
        return try {
            outputStream?.write(msg.toByteArray())
            true
        } catch (e: Exception) { 
            logToFlutter("[오류] 메시지 전송 실패")
            false 
        }
    }
}
