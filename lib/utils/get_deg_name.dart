getDegName(double deg) {
  if (deg >= 337.5 || deg < 22.5) {
    return '右';
  }
  if (deg >= 22.5 && deg < 67.5) {
    return '右前方';
  }
  if (deg >= 67.5 && deg < 112.5) {
    return '上';
  }
  if (deg >= 112.5 && deg < 157.5) {
    return '左前方';
  }
  if (deg >= 157.5 && deg < 202.5) {
    return '左';
  }
  if (deg >= 202.5 && deg < 247.5) {
    return '左後方';
  }
  if (deg >= 247.5 && deg < 292.5) {
    return '下';
  }
  if (deg >= 292.5 && deg < 337.5) {
    return '右後方';
  }
}
