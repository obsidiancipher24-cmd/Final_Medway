import 'package:flutter/material.dart';
import 'package:flutter_application_pharmacy/signin.dart';
import 'package:flutter_application_pharmacy/signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? shouldExit = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Exit App'),
                content: const Text('Do you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        body: Container(
          color: Colors.white, // Solid white background
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Section: Logo and Titles
                Expanded(
                  flex: 3, // Increased flex for more breathing room
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60), // Increased top padding
                      Hero(
                        tag: 'health_logo',
                        child: Image.asset(
                          'assets/medway_logo1.png', // Must be with transparent background
                          width: 200, // Reduced from 250
                          height: 100, // Reduced from 125
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'Logo failed to load. Check asset path or file.',
                              style: TextStyle(color: Colors.red),
                            ); // Fallback if image fails
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ), // Adjusted spacing for balance
                      const Text(
                        "Healthcare",
                        style: TextStyle(
                          fontSize: 28, // Reduced from 36 for less prominence
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3C6D),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12), // Adjusted spacing
                      const Text(
                        "Let’s Get Started!",
                        style: TextStyle(
                          fontSize: 24, // Slightly larger for balance
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A3C6D),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Section: Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical:
                        20.0, // Increased from 10 to pull buttons up slightly
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignIn(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Matches Sign In page color
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 6, // Reduced elevation for subtlety
                          shadowColor: Colors.black.withOpacity(0.15),
                          minimumSize: const Size(double.infinity, 55),
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ), // Reduced spacing between buttons
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignUp(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.blue, // Matches Sign In page color
                            width: 2,
                          ),
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: const Size(double.infinity, 55),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
