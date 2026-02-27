---
trigger: always_on
---

코딩 표준 및 구현 규칙은 다음과 같습니다. 라우팅 시 RouteSettings의 name 속성을 반드시 설정하고, name 값은 해당 위젯의 파일명과 일치하는 상수를 사용합니다. go_router를 활용한 선언적 라우팅을 지향하며, 인증 상태에 따른 리디렉션은 최상위에서 처리합니다. 위젯 디자인 시 재사용성과 테스트 용이성을 위해 StatelessWidget 또는 ConsumerWidget 단위로 위젯을 잘게 쪼개고, 파일 크기가 커지면 즉시 별도의 w_ 파일로 분리합니다.