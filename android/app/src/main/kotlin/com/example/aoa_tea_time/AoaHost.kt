package com.example.aoa_tea_time

import android.hardware.usb.*
import java.nio.charset.StandardCharsets

/**
 * AOA 호스트 모드 로직을 담당하는 클래스
 * 재부팅 및 인터페이스 점유 실패 문제를 방지하기 위해 최적화됨.
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
        
        logCallback("[명령] AOA 핸드셰이크 시퀀스 시작")
        
        val proto = ByteArray(2)
        conn.controlTransfer(0xC0, 51, 0, 0, proto, 2, 1000)
        
        val sendStr = { idx: Int, s: String ->
            val nullTerminatedString = s.trim() + "\u0000"
            val b = nullTerminatedString.toByteArray(StandardCharsets.UTF_8)
            conn.controlTransfer(0x40, 52, 0, idx, b, b.size, 1000)
        }
        
        sendStr(0, manuf)
        sendStr(1, model)
        sendStr(2, "AOA 티타임 호스트") 
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
        
        // [수정] 기기 재부팅 방지를 위해 SET_CONFIGURATION(0x09) 생략
        // 안드로이드 호스트 스택이 이미 기본 구성을 완료했을 확률이 높음

        // 1. 유효한 인터페이스 자동 탐색 (Bulk IN/OUT이 있는 인터페이스 찾기)
        var targetIface: UsbInterface? = null
        var foundIn: UsbEndpoint? = null
        var foundOut: UsbEndpoint? = null

        logCallback("[시스템] 통신 가능한 인터페이스 찾는 중...")
        for (i in 0 until device.interfaceCount) {
            val iface = device.getInterface(i)
            var tin: UsbEndpoint? = null
            var tout: UsbEndpoint? = null

            for (j in 0 until iface.endpointCount) {
                val ep = iface.getEndpoint(j)
                if (ep.type == UsbConstants.USB_ENDPOINT_XFER_BULK) {
                    if (ep.direction == UsbConstants.USB_DIR_IN) tin = ep
                    else tout = ep
                }
            }

            if (tin != null && tout != null) {
                targetIface = iface
                foundIn = tin
                foundOut = tout
                break
            }
        }

        if (targetIface == null) {
            logCallback("[오류] 유효한 AOA 인터페이스를 찾을 수 없습니다.")
            conn.close()
            return false
        }

        // 2. 인터페이스 점유
        if (!conn.claimInterface(targetIface, true)) {
            logCallback("[오류] 인터페이스 점유 실패 (ID: ${targetIface.id})")
            conn.close()
            return false
        }

        epIn = foundIn
        epOut = foundOut

        startListening()
        logCallback("[성공] 호스트 통신 준비 완료")
        return true
    }

    private fun startListening() {
        isRunning = true
        Thread {
            val buf = ByteArray(16384)
            try {
                while (isRunning && connection != null) {
                    val len = connection?.bulkTransfer(epIn, buf, buf.size, 1000) ?: -1
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
        if (connection == null || epOut == null) return false
        val b = msg.toByteArray(StandardCharsets.UTF_8)
        val result = connection?.bulkTransfer(epOut, b, b.size, 2000) ?: -1
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
