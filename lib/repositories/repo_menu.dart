import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 메뉴 파일 저장 및 관리를 담당하는 리포지토리 클래스
/// 앱 내부 저장소(설정 유지용)와 외부 공용 저장소(파일 선택/내보내기용)를 모두 다룹니다.
class MenuRepository {
  // 앱 내부 저장소에 저장될 파일명 (리뷰나 동기화 상태 유지용)
  static const String _internalFileName = 'menu_config.json';

  // 디바이스 모드에서 메뉴를 읽어오는 고정된 안드로이드 경로
  static const String fixedDownloadPath =
      '/storage/emulated/0/Download/Recipes.json';

  /// 앱 내부 전용 데이터 저장소 경로 조회
  Future<String> get _internalPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// 내부 저장소의 설정 파일 객체 조회
  Future<File> get _internalFile async {
    final path = await _internalPath;
    return File('$path/$_internalFileName');
  }

  // --- [내부 저장소] 관련 메서드 (앱 캐시/중앙 설정 관리) ---

  /// 동기화된 메뉴 JSON 문자열을 내부 저장소에 영구 보관
  Future<bool> saveToInternal(String jsonString) async {
    try {
      final file = await _internalFile;
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 내부 저장소에 저장되어 있는 메뉴 데이터 로드 (앱 재시작 시 호출)
  Future<String?> loadFromInternal() async {
    try {
      final file = await _internalFile;
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 내부 캐시된 메뉴 데이터 삭제
  Future<bool> deleteInternal() async {
    try {
      final file = await _internalFile;
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- [외부 저장소] 및 고정 경로 관련 메서드 (Recipes.json 관리) ---

  /// 안드로이드 다운로드 폴더의 고정 파일(Recipes.json) 내용 로드
  Future<String?> loadFromFixedPath() async {
    try {
      final file = File(fixedDownloadPath);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 고정 파일(Recipes.json)이 현재 존재하는지 여부 확인
  Future<bool> checkFixedFileExists() async {
    return await File(fixedDownloadPath).exists();
  }

  /// 특정 JSON 데이터를 다운로드 폴더로 내보내기 (백업용)
  Future<String?> exportToDownloads(String fileName, String content) async {
    try {
      String? directoryPath;
      if (Platform.isAndroid) {
        // 안드로이드 표준 다운로드 경로
        directoryPath = '/storage/emulated/0/Download';
      } else {
        // iOS/기타 환경용 공용 다운로드 디렉토리
        final directory = await getDownloadsDirectory();
        directoryPath = directory?.path;
      }

      if (directoryPath == null) return null;

      final file = File('$directoryPath/$fileName');
      await file.writeAsString(content);
      return file.path; // 저장된 실제 전체 경로 반환
    } catch (e) {
      return null;
    }
  }
}
