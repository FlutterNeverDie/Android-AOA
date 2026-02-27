package com.example.aoa_tea_time

import android.hardware.usb.UsbAccessory
import android.hardware.usb.UsbManager
import android.os.ParcelFileDescriptor
import java.io.FileInputStream
import java.io.FileOutputStream
import java.nio.charset.StandardCharsets

/** AOA 디바이스 모드(액세서리 수신측) 로직을 담당하는 클래스 */
class AoaDevice(private val usbManager: UsbManager, private val logCallback: (String) -> Unit) {
    private var fileDescriptor: ParcelFileDescriptor? = null
    private var inputStream: FileInputStream? = null
    private var outputStream: FileOutputStream? = null
    private var isRunning = false

    fun isConnected(): Boolean = fileDescriptor != null

    /** 호스트가 개설한 액세서리 세션을 엶 */
    fun setupCommunication(accessory: UsbAccessory): Boolean {
        close() // 기존 연결 정리

        fileDescriptor = usbManager.openAccessory(accessory)
        if (fileDescriptor == null) {
            logCallback("[오류] 액세서리 열기 실패 (권한 요망)")
            return false
        }

        val fd = fileDescriptor!!.fileDescriptor
        inputStream = FileInputStream(fd)
        outputStream = FileOutputStream(fd)

        startListening()
        logCallback("[성공] 디바이스 통신 준비 완료")
        return true
    }

    private fun startListening() {
        isRunning = true
        Thread {
                    val buf = ByteArray(65536) // 16KB -> 64KB로 확장
                    try {
                        while (isRunning && inputStream != null) {
                            val len = inputStream?.read(buf) ?: -1
                            if (len > 0) {
                                val msg = String(buf, 0, len, StandardCharsets.UTF_8)
                                logCallback(msg)
                            }
                        }
                    } catch (e: Exception) {
                        logCallback("[안내] 디바이스 수신 중단: ${e.message}")
                    }
                }
                .start()
    }

    fun sendMessage(msg: String): Boolean {
        return try {
            outputStream?.write(msg.toByteArray(StandardCharsets.UTF_8))
            true
        } catch (e: Exception) {
            logCallback("[오류] 메시지 전송 실패: ${e.message}")
            false
        }
    }

    fun close() {
        isRunning = false
        try {
            inputStream?.close()
            outputStream?.close()
            fileDescriptor?.close()
        } catch (e: Exception) {
            // 무시
        }
        inputStream = null
        outputStream = null
        fileDescriptor = null
    }
}
