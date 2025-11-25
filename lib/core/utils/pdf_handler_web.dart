import 'dart:html' as html;

void openPdfBytes(List<int> bytes) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, "_blank");
  html.Url.revokeObjectUrl(url);
}

void openPdfUrl(String url) {
  html.window.open(url, "_blank");
}
