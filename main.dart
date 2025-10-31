import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

void main() => runApp(SignupAdventureApp());

class SignupAdventureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup Adventure',
      debugShowCheckedModeBanner: false,
      home: SignupScreen(),
    );
  }
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  String? _selectedAvatar;
  double _progress = 0;
  String _progressMessage = "Let's begin!";
  List<String> _badges = [];
  bool _showTooltip = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    double p = 0;
    if (_name.text.isNotEmpty) p += 0.25;
    if (_email.text.isNotEmpty) p += 0.25;
    if (_password.text.isNotEmpty) p += 0.25;
    if (_confirm.text.isNotEmpty) p += 0.25;
    setState(() {
      _progress = p;
      if (p == 0.25) _progressMessage = "Great start!";
      else if (p == 0.5) _progressMessage = "Halfway there!";
      else if (p == 0.75) _progressMessage = "Almost done!";
      else if (p == 1.0) _progressMessage = "Ready for adventure!";
    });
  }

  /// Determine password strength level and color
  Map<String, dynamic> _passwordStrength() {
    final pass = _password.text;
    if (pass.isEmpty) return {'color': Colors.grey, 'label': ''};
    if (pass.length < 4) return {'color': Colors.red, 'label': 'Weak'};
    if (pass.length < 8) return {'color': Colors.orange, 'label': 'Average'};
    if (pass.length < 12) return {'color': Colors.lightGreen, 'label': 'Strong'};
    return {'color': Colors.green, 'label': 'Very Strong'};
  }

  void _checkBadges() {
    final now = DateTime.now();
    final isStrong = _password.text.length >= 8;
    final isEarly = now.hour < 12;
    final isComplete = _progress == 1.0;
    _badges.clear();
    if (isStrong) _badges.add("Strong Password Master");
    if (isEarly) _badges.add("The Early Bird Special");
    if (isComplete) _badges.add("Profile Completer");
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _checkBadges();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            name: _name.text,
            avatar: _selectedAvatar ?? '😊',
            badges: _badges,
          ),
        ),
      );
    } else {
      _shakeController.forward(from: 0);
      setState(() => _showTooltip = true);
    }
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool obscure = false}) {
    bool highlight = controller.text.isEmpty &&
        (_progress < 1.0); // sequential highlighting
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? Colors.amber : Colors.grey.shade400,
          width: highlight ? 2 : 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        onChanged: (_) => _updateProgress(),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'Please enter $label';
          if (label == "Confirm Password" && val != _password.text) {
            return "Passwords don't match";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatars = ['😊', '🚀', '🐱', '🌟', '🎮'];
    final strength = _passwordStrength();

    return Scaffold(
      appBar: AppBar(title: const Text('Signup Adventure')),
      body: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          double offset =
              sin(_shakeController.value * pi * 4) * (_showTooltip ? 8 : 0);
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _progress,
                color: Colors.green,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 10),
              Text(_progressMessage,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField("Name", _name),
                    _buildField("Email", _email),
                    _buildField("Password", _password, obscure: true),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: strength['color'],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          strength['label'],
                          style: TextStyle(
                              color: strength['color'],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildField("Confirm Password", _confirm, obscure: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text("Choose an avatar:"),
              Wrap(
                spacing: 10,
                children: avatars.map((a) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = a),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedAvatar == a
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                      child: Text(a, style: const TextStyle(fontSize: 28)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Sign Up"),
              ),
              if (_showTooltip)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Please correct errors before continuing.",
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final List<String> badges;
  const SuccessScreen(
      {required this.name, required this.avatar, required this.badges});

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti =
        ConfettiController(duration: const Duration(seconds: 2))..play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome!')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.avatar, style: const TextStyle(fontSize: 60)),
                const SizedBox(height: 20),
                Text(
                  "Welcome, ${widget.name}!",
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text("🎉 You've earned these badges:"),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: widget.badges
                      .map((b) => Chip(
                            label: Text(b),
                            backgroundColor: Colors.lightBlueAccent.shade100,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange],
          ),
        ],
      ),
    );
  }
}
