import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'detector/detector.dart';

/// Check if the text has detection
bool isDetected(String value, RegExp detectionRegExp) {
  final decoratedTextColor = Colors.blue;
  final detector = Detector(
    textStyle: TextStyle(),
    detectedStyle: TextStyle(
      color: decoratedTextColor,
    ),
    detectionRegExp: detectionRegExp,
  );
  final result = detector.getDetections(value);
  final detections = result
      .where((detection) => detection.style!.color == decoratedTextColor)
      .toList();
  return detections.isNotEmpty;
}

String shortenUrl(String originalUrl) {
  final uri = Uri.tryParse(originalUrl);
  if (uri != null) {
    var shortenUrl = '${uri.host}${uri.path}${uri.query}';
    if (shortenUrl.startsWith('www.')) {
      shortenUrl = shortenUrl.substring(4);
    }
    if (shortenUrl.length > 27) {
      shortenUrl = shortenUrl.substring(0, 27) + '...';
    }
    return shortenUrl;
  } else {
    return originalUrl;
  }
}

/// Extract detections from the text
List<String> extractDetections(String value, RegExp detectionRegExp) {
  final decoratedTextColor = Colors.blue;
  final decorator = Detector(
    textStyle: TextStyle(),
    detectedStyle: TextStyle(color: decoratedTextColor),
    detectionRegExp: detectionRegExp,
  );
  final decorations = decorator.getDetections(value);
  final taggedDecorations = decorations
      .where((decoration) => decoration.style!.color == decoratedTextColor)
      .toList();
  final result = taggedDecorations.map((decoration) {
    final text = decoration.range.textInside(value);
    return text.trim();
  }).toList();
  return result;
}

/// Returns textSpan with detected text
///
/// Used in [DetectableText]
TextSpan getDetectedTextSpan({
  required TextStyle decoratedStyle,
  required TextStyle basicStyle,
  required String source,
  required RegExp detectionRegExp,
  Function(String)? onTap,
  VoidCallback? onTapRemaining,
  bool isUrlShorten = false,
  bool decorateAtSign = false,
}) {
  final detector = Detector(
    detectedStyle: decoratedStyle,
    textStyle: basicStyle,
    detectionRegExp: detectionRegExp,
  );
  final detections = detector.getDetections(source, isUrlShorten: isUrlShorten);
  if (detections.isEmpty) {
    return TextSpan(text: source, style: basicStyle);
  } else {
    detections.sort();
    final span = detections
        .asMap()
        .map(
          (index, item) {
            final onTapRecognizer = TapGestureRecognizer()
              ..onTap = () {
                final decoration = detections[index];
                if (decoration.style == decoratedStyle) {
                  final text =
                      decoration.range.textInside(detector.shortSource).trim();
                  if (detector.urlMap.containsKey(text)) {
                    onTap!(detector.urlMap[text]!);
                  } else {
                    onTap!(text);
                  }
                } else {
                  if (onTapRemaining != null) {
                    onTapRemaining();
                  }
                }
              };
            return MapEntry(
              index,
              TextSpan(
                style: item.style,
                text: item.range.textInside(detector.shortSource),
                recognizer: (onTap == null && onTapRemaining == null)
                    ? null
                    : onTapRecognizer,
              ),
            );
          },
        )
        .values
        .toList();

    return TextSpan(children: span);
  }
}
