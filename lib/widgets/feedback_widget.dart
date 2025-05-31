import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

/// A feedback widget that collects user ratings and comments
class FeedbackWidget extends StatefulWidget {
  final Function(double rating, String comment)? onSubmit;
  
  const FeedbackWidget({super.key, this.onSubmit});

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_rating > 0) {
      widget.onSubmit?.call(_rating, _commentController.text);
      setState(() => _isSubmitted = true);
      
      // Reset after delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isSubmitted = false;
            _rating = 0;
            _commentController.clear();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isSubmitted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Thank you for your feedback!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate your experience',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: RepaintBoundary(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: theme.colorScheme.secondary,
                ),
                onRatingUpdate: (rating) {
                  setState(() => _rating = rating);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Share your thoughts (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.secondary,
                  width: 2,
                ),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _rating > 0 ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Submit Feedback',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 