String getDegName(double deg) {
  if (deg >= -22.5 && deg < 22.5) {
    return '前';
  }
  if (deg >= 22.5 && deg < 67.5) {
    return 'やや右';
  }
  if (deg >= 67.5 && deg < 112.5) {
    return '右';
  }
  if (deg >= 112.5 && deg < 157.5) {
    return '右後ろ';
  }
  if (deg >= 157.5 || deg < -157.5) {
    return '後ろ';
  }
  if (deg >= -157.5 && deg < -112.5) {
    return '左後ろ';
  }
  if (deg >= -112.5 && deg < -67.5) {
    return '左';
  }
  if (deg >= -67.5 && deg < -22.5) {
    return 'やや左';
  }

  return '不明';
}
