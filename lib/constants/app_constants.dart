/// アプリケーション全体で使用する定数
class AppConstants {
  // 協会名
  static const String assocName = 'セーリング伊勢';
  // レース名
  static const String raceName = '全国ハンザクラスブラインドセーリング大会';

  // マーク数
  static const int markNum = 3;

  // 案内できる最大距離 (これ以上は不正値として処理)
  static const int maxDistance = 10000;

  // TTS初期値
  static const double ttsSpeedInit = 0.9;
  static const double ttsVolumeInit = 1.0;
  static const double ttsPitchInit = 1.0;
  static const double ttsDurationInit = 1.0;

  // 到達判定の設定
  static const int reachJudgeRadiusInit = 5;
  static const int reachNoticeNumInit = 2;

  // 方位補正初期値
  static const double headingFixInit = 0.0;

  // マーク名タイプ初期値 (0: 上/下マーク, 1: 数字マーク)
  static const int markNameTypeInit = 0;

  // 標準マーク名
  static const Map<int, List<String>> standardMarkNames = {
    1: ['上', 'かみ'],
    2: ['サイド', 'さいど'],
    3: ['下', 'しも'],
  };

  // 数字マーク名
  static const Map<int, List<String>> numericMarkNames = {
    1: ['1', 'いち'],
    2: ['2', 'に'],
    3: ['3', 'さん'],
  };

  // アップデート間隔（ミリ秒）
  static const int batteryUpdateInterval = 10000;
  static const int locationUpdateInterval = 1000;

  // 位置精度の閾値
  static const double locationAccuracyThreshold = 30.0;

  // TTS設定
  static const String ttsLanguage = 'ja-JP';
  static const double ttsVolume = 1.0;
  static const double ttsPitch = 1.0;

  // インターネットに接続されていない場合のダイアログ表示
  static const String noConnectionDialogTitle = 'インターネットに接続されていません';
  static const String noConnectionDialogContent =
      'B-SAMを利用するにはインターネットの接続が必要です。SIMカードの有効期限が切れていないか確認してください。';
}
