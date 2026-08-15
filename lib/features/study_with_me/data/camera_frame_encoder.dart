import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

/// Encodes a [CameraImage] stream frame to JPEG without [CameraController.takePicture].
abstract final class CameraFrameEncoder {
  static const _jpegQuality = 65;
  static const _maxWidth = 480;

  static Uint8List? toJpeg(CameraImage image) {
    try {
      if (image.format.group == ImageFormatGroup.jpeg &&
          image.planes.length == 1) {
        return _maybeDownscaleJpeg(image.planes[0].bytes);
      }
      if (image.format.group == ImageFormatGroup.bgra8888) {
        return _encodeBgra(image);
      }
      if (image.format.group == ImageFormatGroup.yuv420) {
        return _encodeYuv420(image);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Uint8List? _maybeDownscaleJpeg(Uint8List jpegBytes) {
    final decoded = img.decodeImage(jpegBytes);
    if (decoded == null) return jpegBytes;
    return _encodeSized(decoded);
  }

  static Uint8List? _encodeBgra(CameraImage image) {
    final plane = image.planes[0];
    final decoded = img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: plane.bytes.buffer,
      bytesOffset: plane.bytes.offsetInBytes,
      rowStride: plane.bytesPerRow,
      order: img.ChannelOrder.bgra,
    );
    return _encodeSized(decoded);
  }

  static Uint8List? _encodeYuv420(CameraImage image) {
    final rgb = _yuv420ToImage(image);
    if (rgb == null) return null;
    return _encodeSized(rgb);
  }

  static Uint8List _encodeSized(img.Image source) {
    final resized = source.width > _maxWidth
        ? img.copyResize(source, width: _maxWidth)
        : source;
    return Uint8List.fromList(img.encodeJpg(resized, quality: _jpegQuality));
  }

  static img.Image? _yuv420ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final out = img.Image(width: width, height: height);
    var uvRowStride = uPlane.bytesPerRow;
    var uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final yIndex = y * yPlane.bytesPerRow + x;
        final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final yValue = yPlane.bytes[yIndex];
        final uValue = uPlane.bytes[uvIndex];
        final vValue = vPlane.bytes[uvIndex];

        final r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
            .clamp(0, 255)
            .toInt();
        final b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();
        out.setPixelRgb(x, y, r, g, b);
      }
    }
    return out;
  }
}
