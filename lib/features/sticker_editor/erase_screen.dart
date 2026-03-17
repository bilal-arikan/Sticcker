import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Result of the erase operation.
class EraseResult {
  /// Path to the erased preview PNG (for display).
  final String previewPath;

  /// Path to the grayscale mask PNG (white=keep, black=erase).
  /// Used to apply the mask to all frames of animated media via FFmpeg.
  final String maskPath;

  EraseResult({required this.previewPath, required this.maskPath});
}

/// Screen that lets users paint areas of an image to make them transparent.
/// Returns an [EraseResult] with preview and mask paths, or null if cancelled.
class EraseScreen extends StatefulWidget {
  final String imagePath;

  const EraseScreen({super.key, required this.imagePath});

  @override
  State<EraseScreen> createState() => _EraseScreenState();
}

class _EraseScreenState extends State<EraseScreen> {
  ui.Image? _image;
  double _brushSize = 25.0;
  final List<_EraseStroke> _strokes = [];
  List<Offset>? _currentStroke;
  bool _saving = false;
  final GlobalKey _canvasKey = GlobalKey();

  // For pinch-to-zoom
  double _scale = 1.0;
  double _prevScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _prevOffset = Offset.zero;
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final file = File(widget.imagePath);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() => _image = frame.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Silgi'),
        actions: [
          // Undo button
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _strokes.isEmpty
                ? null
                : () => setState(() => _strokes.removeLast()),
          ),
          // Save button
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _strokes.isEmpty ? null : _saveResult,
            ),
        ],
      ),
      body: Column(
        children: [
          // Canvas
          Expanded(
            child: _image == null
                ? const Center(child: CircularProgressIndicator())
                : Listener(
                    onPointerDown: (_) => _pointerCount++,
                    onPointerUp: (_) => _pointerCount--,
                    onPointerCancel: (_) => _pointerCount--,
                    child: GestureDetector(
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      onScaleEnd: _onScaleEnd,
                      child: ClipRect(
                        child: RepaintBoundary(
                          key: _canvasKey,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _ErasePainter(
                              image: _image!,
                              strokes: _strokes,
                              currentStroke: _currentStroke,
                              brushSize: _brushSize,
                              scale: _scale,
                              offset: _offset,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          // Brush size slider
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.white54),
                Expanded(
                  child: Slider(
                    value: _brushSize,
                    min: 5,
                    max: 80,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _brushSize = v),
                  ),
                ),
                const Icon(Icons.circle, size: 24, color: Colors.white54),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _prevScale = _scale;
    _prevOffset = _offset;
    if (_pointerCount <= 1) {
      final pos = _toImageCoords(details.localFocalPoint);
      if (pos != null) {
        _currentStroke = [pos];
      }
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_pointerCount > 1) {
      setState(() {
        _scale = (_prevScale * details.scale).clamp(0.5, 5.0);
        _offset = _prevOffset + details.focalPointDelta;
      });
      _currentStroke = null;
    } else if (_currentStroke != null) {
      final pos = _toImageCoords(details.localFocalPoint);
      if (pos != null) {
        setState(() {
          _currentStroke!.add(pos);
        });
      }
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_currentStroke != null && _currentStroke!.isNotEmpty) {
      setState(() {
        _strokes.add(_EraseStroke(
          points: List.from(_currentStroke!),
          brushSize: _brushSize,
        ));
        _currentStroke = null;
      });
    }
  }

  Offset? _toImageCoords(Offset screenPoint) {
    if (_image == null) return null;
    final canvasBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (canvasBox == null) return null;

    final canvasSize = canvasBox.size;
    final imgW = _image!.width.toDouble();
    final imgH = _image!.height.toDouble();

    final scaleX = canvasSize.width / imgW;
    final scaleY = canvasSize.height / imgH;
    final fitScale = scaleX < scaleY ? scaleX : scaleY;
    final displayW = imgW * fitScale;
    final displayH = imgH * fitScale;
    final displayLeft = (canvasSize.width - displayW) / 2;
    final displayTop = (canvasSize.height - displayH) / 2;

    final adjustedX = (screenPoint.dx - _offset.dx - displayLeft * _scale) / (_scale * fitScale);
    final adjustedY = (screenPoint.dy - _offset.dy - displayTop * _scale) / (_scale * fitScale);

    if (adjustedX < 0 || adjustedX > imgW || adjustedY < 0 || adjustedY > imgH) {
      return null;
    }

    return Offset(adjustedX, adjustedY);
  }

  /// Helper to draw erase strokes on a canvas
  void _drawEraseStrokes(Canvas canvas, List<_EraseStroke> strokes, Paint paint) {
    for (final stroke in strokes) {
      paint.strokeWidth = stroke.brushSize;
      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.brushSize / 2,
            paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      } else {
        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  Future<void> _saveResult() async {
    if (_image == null || _saving) return;
    setState(() => _saving = true);

    try {
      final imgW = _image!.width;
      final imgH = _image!.height;
      final ts = DateTime.now().millisecondsSinceEpoch;
      final dir = Directory.systemTemp;

      // === 1. Generate erased preview PNG ===
      final previewRecorder = ui.PictureRecorder();
      final previewCanvas = Canvas(previewRecorder, Rect.fromLTWH(0, 0, imgW.toDouble(), imgH.toDouble()));
      previewCanvas.drawImage(_image!, Offset.zero, Paint());

      final erasePaint = Paint()
        ..blendMode = BlendMode.clear
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      _drawEraseStrokes(previewCanvas, _strokes, erasePaint);

      final previewPicture = previewRecorder.endRecording();
      final previewImage = await previewPicture.toImage(imgW, imgH);
      final previewData = await previewImage.toByteData(format: ui.ImageByteFormat.png);
      if (previewData == null) throw Exception('Failed to encode preview');

      final previewPath = '${dir.path}/erased_$ts.png';
      await File(previewPath).writeAsBytes(previewData.buffer.asUint8List());

      // === 2. Generate RGBA mask PNG ===
      // White+opaque (255,255,255,255) = keep, transparent (0,0,0,0) = erase
      // Used with FFmpeg blend=all_mode=multiply to zero out erased pixels
      final maskRecorder = ui.PictureRecorder();
      final maskCanvas = Canvas(maskRecorder, Rect.fromLTWH(0, 0, imgW.toDouble(), imgH.toDouble()));

      // saveLayer needed for BlendMode.clear to work
      maskCanvas.saveLayer(Rect.fromLTWH(0, 0, imgW.toDouble(), imgH.toDouble()), Paint());

      // Fill with white opaque (keep everything by default)
      maskCanvas.drawRect(
        Rect.fromLTWH(0, 0, imgW.toDouble(), imgH.toDouble()),
        Paint()..color = const Color(0xFFFFFFFF),
      );

      // Clear erased areas to fully transparent (0,0,0,0)
      final maskPaint = Paint()
        ..blendMode = BlendMode.clear
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      _drawEraseStrokes(maskCanvas, _strokes, maskPaint);

      maskCanvas.restore(); // end saveLayer

      final maskPicture = maskRecorder.endRecording();
      final maskImage = await maskPicture.toImage(imgW, imgH);
      final maskData = await maskImage.toByteData(format: ui.ImageByteFormat.png);
      if (maskData == null) throw Exception('Failed to encode mask');

      final maskPath = '${dir.path}/erase_mask_$ts.png';
      await File(maskPath).writeAsBytes(maskData.buffer.asUint8List());

      debugPrint('[EraseScreen] Saved preview: $previewPath, mask: $maskPath');

      if (mounted) {
        Navigator.pop(context, EraseResult(previewPath: previewPath, maskPath: maskPath));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _EraseStroke {
  final List<Offset> points;
  final double brushSize;

  _EraseStroke({required this.points, required this.brushSize});
}

class _ErasePainter extends CustomPainter {
  final ui.Image image;
  final List<_EraseStroke> strokes;
  final List<Offset>? currentStroke;
  final double brushSize;
  final double scale;
  final Offset offset;

  _ErasePainter({
    required this.image,
    required this.strokes,
    this.currentStroke,
    required this.brushSize,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    _drawCheckerboard(canvas, size);

    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();
    final scaleX = size.width / imgW;
    final scaleY = size.height / imgH;
    final fitScale = scaleX < scaleY ? scaleX : scaleY;
    final displayW = imgW * fitScale;
    final displayH = imgH * fitScale;
    final displayLeft = (size.width - displayW) / 2;
    final displayTop = (size.height - displayH) / 2;

    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    canvas.saveLayer(Rect.fromLTWH(displayLeft, displayTop, displayW, displayH), Paint());

    canvas.translate(displayLeft, displayTop);
    canvas.scale(fitScale);
    canvas.drawImage(image, Offset.zero, Paint());

    final erasePaint = Paint()
      ..blendMode = BlendMode.clear
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      erasePaint.strokeWidth = stroke.brushSize;
      _drawStroke(canvas, stroke.points, erasePaint);
    }

    if (currentStroke != null && currentStroke!.isNotEmpty) {
      erasePaint.strokeWidth = brushSize;
      _drawStroke(canvas, currentStroke!, erasePaint);
    }

    canvas.restore();
    canvas.restore();
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length == 1) {
      canvas.drawCircle(points.first, paint.strokeWidth / 2,
          paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    } else {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawCheckerboard(Canvas canvas, Size size) {
    const cellSize = 12.0;
    final lightPaint = Paint()..color = const Color(0xFF3A3A3A);
    final darkPaint = Paint()..color = const Color(0xFF2A2A2A);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), darkPaint);

    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        final isLight = ((x ~/ cellSize) + (y ~/ cellSize)) % 2 == 0;
        if (isLight) {
          canvas.drawRect(Rect.fromLTWH(x, y, cellSize, cellSize), lightPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ErasePainter oldDelegate) => true;
}
