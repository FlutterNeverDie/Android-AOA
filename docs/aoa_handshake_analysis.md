# AOA (Android Open Accessory) 프로토콜 핸드셰이크 메커니즘 분석

## 1. 개요 (Introduction)
본 문서는 안드로이드 기기가 외부 USB 하드웨어(Accessory)와 통신하기 위해 사용하는 **AOA(Android Open Accessory)** 프로토콜의 연결 과정, 일명 '핸드셰이크(Handshake)' 메커니즘을 상세히 분석한다. AOA는 안드로이드 기기가 USB 호스트(Host)가 아닌 USB 주변기기(Peripheral) 모드로 동작하면서도, 연결된 액세서리로부터 전원을 공급받고 데이터를 주고받을 수 있게 설계된 특수 프로토콜이다.

---

## 2. AOA 핸드셰이크 8단계 프로세스 (Handshake Sequence)

AOA 연결은 단순히 케이블을 꽂는다고 이루어지지 않는다. 호스트(액세서리 역할을 하는 기기)와 타겟(안드로이드 폰) 간의 정교한 확인 절차가 필요하며, 이를 **8단계 핸드셰이크**라고 부른다.

### Step 1: 주변기기 연결 확인 (Wait for Device)
*   **설명**: USB 호스트는 USB 포트에 새로운 장치(안드로이드 기기)가 연결될 때까지 대기한다.
*   **동작**: 물리적 연결이 감지되면 USB 버스에 전원을 공급하고 장치 정보를 읽기 시작한다.

### Step 2: 초기 장치 정보 조회 (Get Device Descriptor)
*   **설명**: 호스트는 연결된 기기의 `Vendor ID(VID)`와 `Product ID(PID)`를 조회한다.
*   **핵심**: 만약 기기가 이미 **AOA 모드(VID: 0x18D1, PID: 0x2D00 또는 0x2D01)**라면, 핸드셰이크를 건너뛰고 바로 Step 7(데이터 통신)로 진입한다. 일반 모드라면 다음 단계로 진행한다.

### Step 3: AOA 프로토콜 버전 확인 (Get Protocol Version)
*   **명령**: `Control Transfer (Request Type: 0xC1, Request: 51)`
*   **설명**: 호스트는 기기에게 "너 AOA 프로토콜 몇 버전까지 지원해?"라고 묻는다.
*   **결과**: 기기가 `0`이 아닌 숫자를 반환하면 AOA를 지원하는 기기로 판단한다. (보통 v1 또는 v2 반환)

### Step 4: 액세서리 식별 정보 전송 (Send Identifying Strings)
*   **명령**: `Control Transfer (Request Type: 0x40, Request: 52)`
*   **설명**: 호스트는 자신의 정보를 기기에 전달한다. 이 정보는 나중에 기기에서 어떤 앱을 실행할지 결정하는 근거가 된다.
    *   `manufacturer`: 제조사명
    *   `model`: 모델명
    *   `description`: 상세 설명
    *   `version`: 액세서리 버전
    *   `uri`: 관련 웹사이트 URL
    *   `serial`: 시리얼 번호

### Step 5: 액세서리 모드 전환 요청 (Switch to Accessory Mode)
*   **명령**: `Control Transfer (Request Type: 0x40, Request: 53)`
*   **설명**: 모든 정보 전달이 끝나면 호스트는 기기에게 "이제 USB 버스를 재시작하고 액세서리 모드로 변신해!"라고 명령한다.

### Step 6: 장치 재열거 (Device Re-enumeration)
*   **설명**: 단계 5의 명령을 받은 안드로이드 기기는 잠시 연결을 끊었다가 새로운 USB ID(`VID: 0x18D1`, `PID: 0x2D01`)를 가진 상태로 다시 나타난다.
*   **특징**: 이때 시스템은 수신된 `Identifying Strings`를 확인하여 설치된 앱 중 적절한 앱을 자동으로 실행하거나 권한 팝업을 띄운다.

### Step 7: 인터페이스 및 엔드포인트 설정 (Setting up Communication)
*   **설명**: 호스트는 새로운 ID로 나타난 기기를 다시 찾아 인터페이스와 벌크 통신(Bulk)을 위한 엔드포인트(`IN` / `OUT`)를 연다.
*   **동작**: 벌크 통신 하이웨이가 개설됨으로써 대량의 데이터 송수신 준비가 완료된다.

### Step 8: 데이터 송수신 (Data Exchange)
*   **설명**: 양방향 통신이 시작된다. 호스트는 `Bulk OUT`으로 데이터를 보내고, 안드로이드 기기는 `Bulk IN`으로 데이터를 받는다 (또는 그 반대).

---

## 3. 기술적 특징 및 장점 (Technical Insights)

1.  **전원 공급 독립성**: 안드로이드 기기가 USB 주변기기로 동작하므로, USB 호스트(액세서리)로부터 충전 전력을 안정적으로 공급받을 수 있다. (배터리 소모 방지)
2.  **드라이버 프리(Driver-less)**: 안드로이드 기기에 별도의 드라이버를 설치할 필요 없이 표준 USB 프로토콜만으로 통신이 가능하다.
3.  **앱 자동 실행**: 인텐트 필터(`android.hardware.usb.action.USB_ACCESSORY_ATTACHED`)를 통해 케이블 연결 시 지정된 앱을 즉시 실행하여 사용자 경험을 극대화한다.

---

## 4. 결론 (Conclusion)
AOA 핸드셰이크는 단순한 연결을 넘어 '누가 이 통신의 주도권을 쥐고 있는가'를 협상하는 과정이다. 본 프로젝트에서는 이 8단계를 하드웨어 레벨에서 정밀하게 제어하여, 두 안드로이드 기기가 마치 전용 하드웨어처럼 결합되어 동작하도록 구현되었다.
