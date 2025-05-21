import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/mongo_service.dart';
import 'home_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterScreen extends StatefulWidget {
  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final MongoService _mongoService = MongoService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mongoService.connect();
  }

  @override
  void dispose() {
    _mongoService.close();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _mongoService.registerUser(
          emailController.text.trim(),
          passwordController.text.trim(),
          nameController.text.trim(),
          surnameController.text.trim(),
          birthDateController.text.trim(),
          phoneController.text.trim(),
        );

        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('register_success'.tr())));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('email', emailController.text.trim());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('email_already_registered'.tr())),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'error_occurred'.tr()}: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
        ),
        title: Text(
          'register'.tr(),
          style: TextStyle(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
                Theme.of(context).colorScheme.secondary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        15,
                      ), // Adjust the radius as needed
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        height: 100, // Adjust the height as needed
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'name'.tr(),
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ), // Added label text color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white, // Changed fill color to white
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.black87,
                        ), // Added icon color
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ), // Added input text color
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_name'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: surnameController,
                      decoration: InputDecoration(
                        labelText: 'surname'.tr(),
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ), // Added label text color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white, // Changed fill color to white
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.black87,
                        ), // Added icon color
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ), // Added input text color
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_surname'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: birthDateController,
                      decoration: InputDecoration(
                        labelText: 'birth_date'.tr(),
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ), // Added label text color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white, // Changed fill color to white
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.black87,
                        ), // Added icon color
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ), // Added input text color
                      readOnly: true, // Prevent manual editing
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"; // Format the date
                          birthDateController.text =
                              formattedDate; // Set the formatted date to the controller
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_birth_date'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'phone_number'.tr(),
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ), // Added label text color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white, // Changed fill color to white
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Colors.black87,
                        ), // Added icon color
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ), // Added input text color
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_phone_number'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'email'.tr(),
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ), // Added label text color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white, // Changed fill color to white
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.black87,
                        ), // Added icon color
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ), // Added input text color
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_email'.tr();
                        }
                        if (!RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        ).hasMatch(value)) {
                          return 'invalid_email'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'password'.tr(),
                        labelStyle: TextStyle(
                          color: Colors.black87,
                        ), // Added label text color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white, // Changed fill color to white
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.black87,
                        ), // Added icon color
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ), // Added input text color
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_password'.tr();
                        }
                        if (value.length < 6) {
                          return 'password_length'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 30,
                            ),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _handleRegister,
                          child: Text('register'.tr()),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
