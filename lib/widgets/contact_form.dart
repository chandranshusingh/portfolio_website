import 'package:flutter/material.dart';

/// ContactForm: A posh, accessible contact/booking form for consulting inquiries.
/// Includes validation, ARIA labels, and placeholder EmailJS integration.
class ContactForm extends StatefulWidget {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  String? _submitResult;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _submitResult = null;
    });
    
    // Simulate form submission - Replace with actual EmailJS/Formspree integration
    // Example: await EmailJS.send('your_service_id', 'your_template_id', templateParams);
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isSubmitting = false;
      _submitResult = 'Thank you! Your message has been sent successfully.';
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Contact / Book a Consultation',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              hintText: 'Enter your name',
            ),
            validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your name' : null,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              hintText: 'Enter your email',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your email';
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
              return null;
            },
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
              hintText: 'How can I help you?',
            ),
            validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your message' : null,
            minLines: 4,
            maxLines: 8,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Send Message'),
          ),
          if (_submitResult != null) ...[
            const SizedBox(height: 18),
            Text(
              _submitResult!,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 