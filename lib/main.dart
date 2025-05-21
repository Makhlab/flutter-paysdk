import 'package:flutter/material.dart';
import 'payment_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'examples/payment_widget_examples.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'TreezPay Demo',
          theme: ThemeData(
            primaryColor: const Color(0xFF8ccc52),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8ccc52),
              secondary: const Color(0xFF4a7c2a),
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).copyWith(
              titleLarge: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2c3e50),
              ),
              bodyLarge: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF2c3e50),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF8ccc52),
                  width: 2,
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8ccc52),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
          home: const HomeScreen(),
          routes: {
            '/payment': (context) {
              // Get the amount from the arguments or use a default value
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              final amount = args?['amount'] as String? ?? '0.00';
              final channel = args?['channel'] as String? ?? 'virtual_terminal';
              return PaymentScreen(amount: amount, channel: channel);
            },
            '/examples': (context) => const PaymentExamples(),
          },
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _amount = '';
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  String _errorMessage = '';
  String _selectedChannel = 'virtual_terminal'; // Default value

  final List<Map<String, String>> _channelOptions = [
    {'value': 'virtual_terminal', 'label': 'Virtual Terminal'},
    {'value': 'ecommerce', 'label': 'E-Commerce'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _appendDigit(String digit) {
    _animationController.forward(from: 0.0);

    setState(() {
      _errorMessage = '';
      
      // Don't allow multiple decimal points
      if (digit == '.' && _amount.contains('.')) {
        return;
      }
      
      // Don't allow more than 2 decimal places
      if (_amount.contains('.') &&
          _amount.split('.')[1].length >= 2 &&
          digit != '.') {
        return;
      }

      // Limit to a reasonable amount
      if (_amount.isEmpty && digit == '.') {
        _amount = '0.';
      } else if (_amount.isEmpty && digit == '0') {
        _amount = '0';
      } else if (_amount == '0' && digit != '.') {
        _amount = digit;
      } else {
        _amount = _amount + digit;
      }
      
      // Format the amount with commas for thousands
      _controller.text = _formatAmount(_amount);
    });
  }

  void _backspace() {
    _animationController.forward(from: 0.0);
    
    setState(() {
      _errorMessage = '';
      if (_amount.isNotEmpty) {
        _amount = _amount.substring(0, _amount.length - 1);
        _controller.text = _formatAmount(_amount);
      }
    });
  }

  void _clear() {
    _animationController.forward(from: 0.0);
    
    setState(() {
      _errorMessage = '';
      _amount = '';
      _controller.text = '';
    });
  }

  String _formatAmount(String amount) {
    if (amount.isEmpty) return '';
    
    try {
      // Format with commas for thousands, preserve decimal part
      final parts = amount.split('.');
      final intPart = int.parse(parts[0]);
      final formatted = intPart.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      
      if (parts.length > 1) {
        return '$formatted.${parts[1]}';
      }
      return formatted;
    } catch (e) {
      return amount;
    }
  }

  bool _validateAmount() {
    if (_amount.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an amount';
      });
      return false;
    }
    
    if (_amount == '0' || _amount == '0.0' || _amount == '0.00') {
      setState(() {
        _errorMessage = 'Amount must be greater than zero';
      });
      return false;
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf5f7fa),
              Color(0xFFe8f0fc),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Container(
                  alignment: Alignment.center,
                  child: Image.network(
                    'https://js.dev.treezpay.com/logo.svg', // TreezPay logo
                    height: 60,
                    errorBuilder: (context, error, stackTrace) => 
                      const Text('TreezPay', 
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8ccc52),
                        )
                      ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enter Payment Amount',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2c3e50),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.palette),
                      tooltip: 'UI Examples',
                      onPressed: () {
                        Navigator.pushNamed(context, '/examples');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Channel dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Channel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2c3e50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedChannel,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        items: _channelOptions.map((Map<String, String> option) {
                          return DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(option['label']!),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedChannel = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0.00',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 16, right: 8),
                              child: Text(
                                '\$',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2c3e50),
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.none,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2c3e50),
                          ),
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: CustomNumpad(
                    onDigitPressed: _appendDigit,
                    onBackspace: _backspace,
                    onClear: _clear,
                    animationController: _animationController,
                  ),
                ),
                const SizedBox(height: 24),
                ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0)
                      .animate(CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeInOut,
                  )),
                  child: ElevatedButton(
                    onPressed: _amount.isEmpty ? null : () {
                      if (_validateAmount()) {
                        // Remove formatting for the actual amount
                        final cleanAmount = _amount.replaceAll(',', '');
                        
                        // Pass the payment amount and channel to the payment screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              amount: cleanAmount,
                              channel: _selectedChannel,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: Text(
                      'Continue to Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _amount.isEmpty
                            ? Colors.grey.shade500
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomNumpad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final AnimationController animationController;

  const CustomNumpad({
    Key? key,
    required this.onDigitPressed,
    required this.onBackspace,
    required this.onClear,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(child: _buildNumpadRow(['1', '2', '3'])),
          Expanded(child: _buildNumpadRow(['4', '5', '6'])),
          Expanded(child: _buildNumpadRow(['7', '8', '9'])),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildNumKey('.')),
                Expanded(child: _buildNumKey('0')),
                Expanded(child: _buildActionKey(Icons.backspace_outlined, onBackspace)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadRow(List<String> digits) {
    return Row(
      children: digits.map((digit) => Expanded(child: _buildNumKey(digit))).toList(),
    );
  }

  Widget _buildNumKey(String digit) {
    return NumpadKey(
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2c3e50),
        ),
      ),
      onPressed: () => onDigitPressed(digit),
      animationController: animationController,
    );
  }

  Widget _buildActionKey(IconData icon, VoidCallback onPressed) {
    return NumpadKey(
      child: Icon(
        icon,
        color: const Color(0xFF2c3e50),
        size: 24,
      ),
      onPressed: onPressed,
      animationController: animationController,
    );
  }
}

class NumpadKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final AnimationController animationController;

  const NumpadKey({
    Key? key,
    required this.child,
    required this.onPressed,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          onPressed();
        },
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, _) {
            final pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Curves.easeInOut,
              ),
            );
            
            return Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ScaleTransition(
                scale: pulseAnimation,
                child: Container(
                  alignment: Alignment.center,
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
