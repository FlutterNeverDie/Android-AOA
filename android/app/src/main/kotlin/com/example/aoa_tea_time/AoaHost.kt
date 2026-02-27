package com.example.aoa_tea_time

import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbManager
import java.nio.charset.StandardCharsets

/**
 * AOA 호스트 모드 로직을 담당하는 클래스
 */
class AoaHost(
    private val usbManager: UsbManager,
    private val logCallback: (String) -> Unit
) {
    private var connection: UsbDeviceConnection? = null
    private var epIn: UsbEndpoint? = null
    private var epOut: UsbEndpoint? = null
    private var isRunning = false

    fun isConnected(): Boolean = connection != null

    /**
     * 장치에 AOA 핸드셰이크 신호를 보냄
     */
    fun doHandshake(device: UsbDevice, manuf: String, model: String, ver: String) {
        val conn = usbManager.openDevice(device) ?: run {
            logCallback("[오류] 핸드셰이크용 장치를 열 수 없습니다.")
            return
        }
        
        logCallback("[명령] AOA 핸드셰이크 시퀀스 시작 (제조사: $manuf, 모델: $model)")
        
        val proto = ByteArray(2)
        conn.controlTransfer(0xC0, 51, 0, 0, proto, 2, 1000)
        
        val sendStr = { idx: Int, s: String ->
            val nullTerminatedString = s.trim() + "\u0000"
            val b = nullTerminatedString.toByteArray(StandardCharsets.UTF_8)
            conn.controlTransfer(0x40, 52, 0, idx, b, b.size, 1000)
        }
        
        sendStr(0, manuf)
        sendStr(1, model)
        sendStr(2, "AOA 티타임") // Description
        sendStr(3, ver)
        
        logCallback("[명령] START 신호 전송")
        conn.controlTransfer(0x40, 53, 0, 0, null, 0, 1000)
        conn.close()
    }

    /**
     * AOA 모드로 전환된 장치와 실제 통신 채널을 설정
     */
    fun setupCommunication(device: UsbDevice): Boolean {
        close() // 기존 연결 정리

        val conn = usbManager.openDevice(device) ?: run {
            logCallback("[오류] AOA 장치 연결 실패")
            return false
        }
        
        connection = conn
        
        // AOA 표준: SET_CONFIGURATION (0x09) 요청
        logCallback("[시스템] 기기 구성(Configuration) 활성화 중...")
        conn.controlTransfer(0x00, 0x09, 1, 0, null, 0, 2000)

        // 첫 번째 인터페이스 점유
        val iface = device.getInterface(0)
        if (!conn.claimInterface(iface, true)) {
            logCallback("[오류] 인터페이스 점유 실패")
            return false
        }

        // 벌크 엔드포인트 찾기
        for (i in 0 until iface.endpointCount) {
            val ep = iface.getEndpoint(i)
            if (ep.type == UsbConstants.USB_ENDPOINT_XFER_BULK) {
                if (ep.direction == UsbConstants.USB_DIR_IN) epIn = ep
                else epOut = ep
            }
        }

        if (epIn == null || epOut == null) {
            logCallback("[오류] 엔드포인트를 찾을 수 없습니다.")
            return false
        }

        startListening()
        logCallback("[성공] 호스트 통신 채널 개설 완료")
        return true
    }

    private fun startListening() {
        isRunning = true
        Thread {
            val buf = ByteArray(16384)
            try {
                while (isRunning && connection != null) {
                    val len = connection?.bulkTransfer(epIn, buf, buf.size, 500) ?: -1
                    if (len > 0) {
                        val msg = String(buf, 0, len, StandardCharsets.UTF_8)
                        logCallback("수신됨: $msg")
                    }
                }
            } catch (e: Exception) {
                logCallback("[안내] 수신 루프 종료: ${e.message}")
            }
        }.start()
    }

    fun sendMessage(msg: String): Boolean {
        val b = msg.toByteArray(StandardCharsets.UTF_8)
        val result = connection?.bulkTransfer(epOut, b, b.size, 1000) ?: -1
        return result >= 0
    }

    fun close() {
        isRunning = false
        connection?.close()
        connection = null
        epIn = null
        epOut = null
    }
}
