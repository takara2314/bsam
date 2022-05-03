normalizeDeg(double deg) {
  deg = -deg+90;
  if (deg < 0) {
    deg = 180 - deg;
  }
  return deg;
}

normalizeCompassDeg(double deg) {
  if (deg >= 0) {
    return (450 - deg) % 360;
  }
  return 90 - deg;
}

normalizeRouteDeg(double deg) {
  if (deg < -90) {
    deg = 360 + deg;
  }
  return deg + 90;
}
