String getDegName(double deg) {
  if (deg >= -30 && deg < 30) {
    return '前';
  }
  if (deg >= 30 && deg < 60) {
    return 'やや右前';
  }
  if (deg >= 60 && deg < 120) {
    return '右';
  }
  if (deg >= 120 && deg < 150) {
    return 'やや右後ろ';
  }
  if (deg >= 150 || deg < -150) {
    return '後ろ';
  }
  if (deg >= -150 && deg < -120) {
    return 'やや左後ろ';
  }
  if (deg >= -120 && deg < -60) {
    return '左';
  }
  if (deg >= -60 && deg < -30) {
    return 'やや左前';
  }

  return '不明';
}
