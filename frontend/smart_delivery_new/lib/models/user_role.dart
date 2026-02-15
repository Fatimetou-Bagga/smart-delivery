enum AppLoginRole { client, courier }

String roleToBackend(AppLoginRole r) {
  // adapt if your backend uses different strings
  switch (r) {
    case AppLoginRole.client:
      return 'CLIENT';
    case AppLoginRole.courier:
      return 'COURIER';
  }
}
