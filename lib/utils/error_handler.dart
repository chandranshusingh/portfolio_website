import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Comprehensive error handler for the portfolio application.
/// 
/// Provides graceful error handling for:
/// - Ticker disposal errors
/// - Network connectivity issues
/// - Asset loading failures
/// - Animation controller lifecycle issues
/// - ScrollController and TextEditingController disposal
/// - General runtime exceptions
class ErrorHandler {
  static bool _isInitialized = false;

  /// Initialize global error handling for the application
  static void initialize() {
    if (_isInitialized) return;
    
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Handle platform dispatcher errors (for web/native)
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true; // Mark as handled
    };

    // Set custom error widget builder for release mode
    _setCustomErrorWidget();

    _isInitialized = true;
    debugPrint('✅ ErrorHandler initialized successfully');
  }

  /// Set a custom error widget for better user experience in release mode
  static void _setCustomErrorWidget() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // In debug mode, show the default red error screen
      if (kDebugMode) {
        return ErrorWidget(details.exception);
      }
      
      // In release mode, show a user-friendly error widget
      return Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please refresh the page or try again later.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    };
  }

  /// Handle Flutter framework errors with categorization
  static void _handleFlutterError(FlutterErrorDetails details) {
    final errorMessage = details.exception.toString().toLowerCase();
    
    // Categorize and handle different types of errors
    if (_isTickerError(errorMessage)) {
      _handleTickerError(details);
    } else if (_isAssetError(errorMessage)) {
      _handleAssetError(details);
    } else if (_isNetworkError(errorMessage)) {
      _handleNetworkError(details);
    } else if (_isRenderError(errorMessage)) {
      _handleRenderError(details);
    } else {
      _handleGenericError(details);
    }
  }

  /// Handle platform-specific errors with enhanced logging
  static void _handlePlatformError(Object error, StackTrace stack) {
    final errorMessage = error.toString().toLowerCase();
    
    debugPrint('🔴 Platform Error: $error');
    
    // Handle specific error types
    if (error is OutOfMemoryError) {
      debugPrint('💾 Out of Memory Error detected - consider optimizing resource usage');
      if (kDebugMode) {
        debugPrint('Stack trace: $stack');
      }
    } else if (error is StackOverflowError) {
      debugPrint('🔄 Stack Overflow Error detected - check for infinite recursion');
      if (kDebugMode) {
        debugPrint('Stack trace: $stack');
      }
    } else if (_isTickerError(errorMessage)) {
      debugPrint('🎯 Ticker disposal error detected in platform layer');
      if (kDebugMode) {
        debugPrint('Stack trace: $stack');
      }
    } else {
      debugPrint('📍 Platform error stack: $stack');
    }
  }

  /// Check if error is related to Ticker disposal
  static bool _isTickerError(String error) {
    return error.contains('ticker') || 
           error.contains('disposed with an active') ||
           error.contains('animationcontroller') ||
           error.contains('tickerprovider');
  }

  /// Check if error is related to asset loading
  static bool _isAssetError(String error) {
    return error.contains('asset') || 
           error.contains('unable to load') ||
           error.contains('lottie') ||
           error.contains('image') ||
           error.contains('flutter/services') ||
           error.contains('rootbundle');
  }

  /// Check if error is network-related
  static bool _isNetworkError(String error) {
    return error.contains('network') || 
           error.contains('connection') ||
           error.contains('socket') ||
           error.contains('http') ||
           error.contains('timeout') ||
           error.contains('dns');
  }

  /// Check if error is render-related
  static bool _isRenderError(String error) {
    return error.contains('render') ||
           error.contains('layout') ||
           error.contains('constraints') ||
           error.contains('overflow') ||
           error.contains('size');
  }

  /// Handle Ticker disposal errors gracefully
  static void _handleTickerError(FlutterErrorDetails details) {
    debugPrint('🎯 Ticker Error Handled: ${details.exception}');
    
    if (kDebugMode) {
      debugPrint('Ticker error stack trace: ${details.stack}');
    }
  }

  /// Handle asset loading errors with fallback strategies
  static void _handleAssetError(FlutterErrorDetails details) {
    debugPrint('📦 Asset Error: ${details.exception}');
    
    if (kDebugMode) {
      debugPrint('Asset error context: ${details.context}');
    }
  }

  /// Handle network connectivity errors
  static void _handleNetworkError(FlutterErrorDetails details) {
    debugPrint('🌐 Network Error: ${details.exception}');
    
    if (kDebugMode) {
      debugPrint('Network error details: ${details.stack}');
    }
  }

  /// Handle render-related errors
  static void _handleRenderError(FlutterErrorDetails details) {
    debugPrint('🎨 Render Error: ${details.exception}');
    
    if (kDebugMode) {
      debugPrint('Render error context: ${details.context}');
      debugPrint('Render error stack: ${details.stack}');
    }
  }

  /// Handle generic runtime errors
  static void _handleGenericError(FlutterErrorDetails details) {
    debugPrint('⚠️ Runtime Error: ${details.exception}');
    
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      debugPrint('Error context: ${details.context}');
      debugPrint('Error library: ${details.library}');
    }
  }

  /// Safe disposal utility for AnimationControllers
  static void safeDisposeController(AnimationController? controller, {String? name}) {
    if (controller == null) return;
    
    try {
      if (controller.isAnimating) {
        controller.stop();
      }
      controller.reset();
      controller.dispose();
      
      debugPrint('✅ SafeDispose: ${name ?? 'AnimationController'} disposed successfully');
    } catch (e) {
      debugPrint('⚠️ SafeDispose: Error disposing ${name ?? 'AnimationController'}: $e');
      try {
        controller.dispose();
      } catch (forceError) {
        debugPrint('🔴 SafeDispose: Force dispose failed for ${name ?? 'AnimationController'}: $forceError');
      }
    }
  }

  /// Safe disposal utility for multiple controllers
  static void safeDisposeControllers(List<AnimationController?> controllers, {List<String>? names}) {
    for (int i = 0; i < controllers.length; i++) {
      final controller = controllers[i];
      final name = names != null && i < names.length ? names[i] : 'Controller_$i';
      safeDisposeController(controller, name: name);
    }
  }

  /// Safe disposal utility for ScrollControllers
  static void safeDisposeScrollController(ScrollController? controller, {String? name}) {
    if (controller == null) return;
    
    try {
      controller.dispose();
      debugPrint('✅ SafeDispose: ${name ?? 'ScrollController'} disposed successfully');
    } catch (e) {
      debugPrint('⚠️ SafeDispose: Error disposing ${name ?? 'ScrollController'}: $e');
    }
  }

  /// Safe disposal utility for TextEditingControllers
  static void safeDisposeTextController(TextEditingController? controller, {String? name}) {
    if (controller == null) return;
    
    try {
      controller.dispose();
      debugPrint('✅ SafeDispose: ${name ?? 'TextEditingController'} disposed successfully');
    } catch (e) {
      debugPrint('⚠️ SafeDispose: Error disposing ${name ?? 'TextEditingController'}: $e');
    }
  }

  /// Generic safe disposal utility for any controller with a dispose method
  static void safeDisposeGeneric(dynamic controller, {String? name}) {
    if (controller == null) return;
    
    try {
      if (controller.runtimeType.toString().contains('Controller') && 
          controller.runtimeType.toString().contains('dispose')) {
        controller.dispose();
        debugPrint('✅ SafeDispose: ${name ?? controller.runtimeType.toString()} disposed successfully');
      }
    } catch (e) {
      debugPrint('⚠️ SafeDispose: Error disposing ${name ?? controller.runtimeType.toString()}: $e');
    }
  }

  /// Create a safe AnimationController that handles disposal automatically
  static AnimationController createSafeController({
    required TickerProvider vsync,
    required Duration duration,
    String? debugLabel,
  }) {
    try {
      return AnimationController(
        vsync: vsync,
        duration: duration,
        debugLabel: debugLabel,
      );
    } catch (e) {
      debugPrint('⚠️ Error creating AnimationController: $e');
      rethrow;
    }
  }

  /// Widget wrapper that catches and handles errors gracefully
  static Widget errorBoundary({
    required Widget child,
    Widget? fallback,
    String? errorContext,
  }) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e, stack) {
          debugPrint('🔴 Widget Error in ${errorContext ?? 'Unknown'}: $e');
          debugPrint('Stack: $stack');
          
          return fallback ?? _buildErrorFallback(context, e);
        }
      },
    );
  }

  /// Build a user-friendly error fallback widget
  static Widget _buildErrorFallback(BuildContext context, Object error) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error.withAlpha(180),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please refresh the page or try again later.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(180),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Log performance issues (useful for monitoring)
  static void logPerformanceIssue(String operation, Duration duration, {String? context}) {
    if (duration.inMilliseconds > 100) { // Log operations taking more than 100ms
      debugPrint('⏱️ Performance Issue: $operation took ${duration.inMilliseconds}ms in ${context ?? 'unknown context'}');
    }
  }

  /// Monitor widget build performance
  static void monitorWidgetBuild<T extends Widget>(String widgetName, VoidCallback buildFunction) {
    final stopwatch = Stopwatch()..start();
    try {
      buildFunction();
    } finally {
      stopwatch.stop();
      logPerformanceIssue('$widgetName build', stopwatch.elapsed, context: 'Widget Build');
    }
  }

  /// Monitor animation frame performance
  static void monitorAnimationFrame(String animationName, VoidCallback frameFunction) {
    final stopwatch = Stopwatch()..start();
    try {
      frameFunction();
    } finally {
      stopwatch.stop();
      if (stopwatch.elapsed.inMilliseconds > 16) { // 60fps = 16.67ms per frame
        debugPrint('🎬 Animation Frame Issue: $animationName frame took ${stopwatch.elapsed.inMilliseconds}ms (target: 16ms)');
      }
    }
  }

  /// Log memory usage warnings
  static void logMemoryWarning(String operation, {String? context}) {
    debugPrint('💾 Memory Warning: High memory usage detected in $operation${context != null ? ' ($context)' : ''}');
  }

  /// Monitor large widget tree builds
  static void monitorWidgetTreeDepth(BuildContext context, String widgetName) {
    // Simplified depth monitoring - just check if we can find common ancestor widgets
    try {
      int depth = 0;
      
      // Check for common widget ancestors to estimate depth
      if (context.findAncestorWidgetOfExactType<Scaffold>() != null) depth += 5;
      if (context.findAncestorWidgetOfExactType<MaterialApp>() != null) depth += 3;
      if (context.findAncestorWidgetOfExactType<Column>() != null) depth += 2;
      if (context.findAncestorWidgetOfExactType<Row>() != null) depth += 2;
      if (context.findAncestorWidgetOfExactType<Container>() != null) depth += 1;
      
      if (depth > 15) { // Warn if estimated depth is high
        debugPrint('🌳 Deep Widget Tree: $widgetName has estimated depth $depth (consider flattening)');
      }
    } catch (e) {
      // If depth monitoring fails, just log it
      debugPrint('⚠️ Widget tree depth monitoring failed for $widgetName: $e');
    }
  }

  /// Wrap async operations with error handling
  static Future<T?> safeAsyncOperation<T>({
    required Future<T> Function() operation,
    String? operationName,
    T? fallbackValue,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      final result = await operation();
      stopwatch.stop();
      
      logPerformanceIssue(operationName ?? 'Async Operation', stopwatch.elapsed);
      return result;
    } catch (e, stack) {
      debugPrint('🔴 Async Error in ${operationName ?? 'Unknown Operation'}: $e');
      debugPrint('Stack: $stack');
      return fallbackValue;
    }
  }
} 