import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../widgets/dynamic_pdf_form_widget.dart';

class PdfIntegrationHelper {
  static Future<MemoryPdfPageRenderer> createRendererFromPdfBytes(
    Uint8List pdfBytes, {
    int dpi = 200,
    String? backgroundColor,
  }) async {
    final Map<int, Uint8List> pageImages = {};
    final Map<int, double> aspectRatios = {};

    try {
      final pages = await _extractPdfPages(pdfBytes, dpi, backgroundColor);

      for (var entry in pages.entries) {
        pageImages[entry.key] = entry.value.imageData;
        aspectRatios[entry.key] = entry.value.aspectRatio;
      }
    } catch (e) {
      debugPrint('Error creating PDF renderer: $e');
    }

    return MemoryPdfPageRenderer(
      pageImages: pageImages,
      aspectRatios: aspectRatios,
    );
  }

  static Future<Map<int, PdfPageData>> _extractPdfPages(
    Uint8List pdfBytes,
    int dpi,
    String? backgroundColor,
  ) async {
    final Map<int, PdfPageData> pages = {};

    try {
      dynamic pdfDocument = await _openPdfDocument(pdfBytes);

      final pageCount = await _getPdfPageCount(pdfDocument);

      for (int i = 1; i <= pageCount; i++) {
        try {
          final pageData = await _renderPdfPage(
            pdfDocument,
            i,
            dpi,
            backgroundColor,
          );
          pages[i] = pageData;
        } catch (e) {
          debugPrint('Error rendering page $i: $e');
        }
      }
    } catch (e) {
      debugPrint('Error extracting PDF pages: $e');
    }

    return pages;
  }

  static Future<dynamic> _openPdfDocument(Uint8List pdfBytes) async {
    try {
      final dynamic pdfLib = _getPdfLibrary();
      if (pdfLib != null) {
        return await pdfLib.openDocument(pdfBytes);
      }
    } catch (e) {
      debugPrint('Could not open PDF document: $e');
    }
    return null;
  }

  static Future<int> _getPdfPageCount(dynamic document) async {
    try {
      final dynamic pdfLib = _getPdfLibrary();
      if (pdfLib != null && document != null) {
        return await pdfLib.getPageCount(document);
      }
    } catch (e) {
      debugPrint('Could not get page count: $e');
    }
    return 1;
  }

  static Future<PdfPageData> _renderPdfPage(
    dynamic document,
    int pageNumber,
    int dpi,
    String? backgroundColor,
  ) async {
    try {
      final dynamic pdfLib = _getPdfLibrary();
      if (pdfLib != null && document != null) {
        return await pdfLib.renderPage(
          document,
          pageNumber,
          dpi,
          backgroundColor,
        );
      }
    } catch (e) {
      debugPrint('Could not render page $pageNumber: $e');
    }
    return PdfPageData(imageData: Uint8List(0), aspectRatio: 8.5 / 11);
  }

  static dynamic _getPdfLibrary() {
    return null;
  }
}

class PdfPageData {
  final Uint8List imageData;
  final double aspectRatio;

  const PdfPageData({required this.imageData, required this.aspectRatio});
}

abstract class PdfLibraryAdapter {
  Future<dynamic> openDocument(Uint8List pdfBytes);
  Future<int> getPageCount(dynamic document);
  Future<PdfPageData> renderPage(
    dynamic document,
    int pageNumber,
    int dpi,
    String? backgroundColor,
  );
}

class PdfxAdapter implements PdfLibraryAdapter {
  const PdfxAdapter();

  @override
  Future<dynamic> openDocument(Uint8List pdfBytes) async {
    try {
      final dynamic pdfx = _tryImportPdfx();
      if (pdfx != null) {
        return await pdfx.PdfDocument.openData(pdfBytes);
      }
    } catch (e) {
      debugPrint('Could not open PDF with pdfx: $e');
    }
    return null;
  }

  @override
  Future<int> getPageCount(dynamic document) async {
    try {
      if (document != null) {
        return await document.pagesCount;
      }
    } catch (e) {
      debugPrint('Could not get page count: $e');
    }
    return 1;
  }

  @override
  Future<PdfPageData> renderPage(
    dynamic document,
    int pageNumber,
    int dpi,
    String? backgroundColor,
  ) async {
    try {
      final page = await document.getPage(pageNumber);
      final pageImage = await page.render(
        width: page.width * dpi ~/ 72,
        height: page.height * dpi ~/ 72,
        format: 0,
        backgroundColor: backgroundColor ?? '#FFFFFF',
      );

      if (pageImage != null) {
        return PdfPageData(
          imageData: pageImage.bytes,
          aspectRatio: pageImage.width / pageImage.height,
        );
      }
    } catch (e) {
      debugPrint('Could not render page: $e');
    }
    return PdfPageData(imageData: Uint8List(0), aspectRatio: 8.5 / 11);
  }

  dynamic _tryImportPdfx() {
    return null;
  }
}

class SyncfusionPdfAdapter implements PdfLibraryAdapter {
  const SyncfusionPdfAdapter();

  @override
  Future<dynamic> openDocument(Uint8List pdfBytes) async {
    try {
      final dynamic syncfusion = _tryImportSyncfusion();
      if (syncfusion != null) {
        return syncfusion.PdfDocument(inputBytes: pdfBytes);
      }
    } catch (e) {
      debugPrint('Could not open PDF with syncfusion: $e');
    }
    return null;
  }

  @override
  Future<int> getPageCount(dynamic document) async {
    try {
      if (document != null) {
        return document.pages.count;
      }
    } catch (e) {
      debugPrint('Could not get page count: $e');
    }
    return 1;
  }

  @override
  Future<PdfPageData> renderPage(
    dynamic document,
    int pageNumber,
    int dpi,
    String? backgroundColor,
  ) async {
    try {
      // final page = document.pages[pageNumber - 1];
      final dynamic syncfusion = _tryImportSyncfusion();

      if (syncfusion != null) {
        final renderer = syncfusion.PdfRenderer(
          document: document,
          pageCount: 1,
        );

        final image = await renderer.renderPage(pageNumber - 1, dpi: dpi);

        return PdfPageData(
          imageData: image.bytes,
          aspectRatio: image.width / image.height,
        );
      }
    } catch (e) {
      debugPrint('Could not render page: $e');
    }
    return PdfPageData(imageData: Uint8List(0), aspectRatio: 8.5 / 11);
  }

  dynamic _tryImportSyncfusion() {
    return null;
  }
}

class FormRendererFactory {
  static Future<MemoryPdfPageRenderer> createRenderer({
    required Uint8List pdfBytes,
    PdfLibraryAdapter? adapter,
    int dpi = 200,
    String? backgroundColor,
  }) async {
    if (adapter != null) {
      return await _createWithAdapter(adapter, pdfBytes, dpi, backgroundColor);
    }

    return await PdfIntegrationHelper.createRendererFromPdfBytes(
      pdfBytes,
      dpi: dpi,
      backgroundColor: backgroundColor,
    );
  }

  static Future<MemoryPdfPageRenderer> _createWithAdapter(
    PdfLibraryAdapter adapter,
    Uint8List pdfBytes,
    int dpi,
    String? backgroundColor,
  ) async {
    final Map<int, Uint8List> pageImages = {};
    final Map<int, double> aspectRatios = {};

    try {
      final document = await adapter.openDocument(pdfBytes);
      if (document == null) {
        return MemoryPdfPageRenderer(pageImages: {}, aspectRatios: {});
      }

      final pageCount = await adapter.getPageCount(document);

      for (int i = 1; i <= pageCount; i++) {
        try {
          final pageData = await adapter.renderPage(
            document,
            i,
            dpi,
            backgroundColor,
          );
          pageImages[i] = pageData.imageData;
          aspectRatios[i] = pageData.aspectRatio;
        } catch (e) {
          debugPrint('Error rendering page $i: $e');
        }
      }
    } catch (e) {
      debugPrint('Error creating renderer with adapter: $e');
    }

    return MemoryPdfPageRenderer(
      pageImages: pageImages,
      aspectRatios: aspectRatios,
    );
  }
}
