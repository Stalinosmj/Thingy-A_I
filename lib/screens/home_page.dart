import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thingy/database/api_setup.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedImage;
  String? selectedAnswer;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return BlurryModalProgressHUD(
      inAsyncCall: _loading,
      blurEffectIntensity: 4,
      dismissible: false,
      opacity: 0.4,
      color: Colors.cyanAccent,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Thingy AI - Prototype"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  pickImageFromGallery();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Pick an Image",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.contain,
                      width: 250,
                    )
                  : const Text("Please select an Image"),
              const SizedBox(
                height: 20,
              ),
              _selectedImage != null
                  ? TextButton(
                      onPressed: () async {
                        if (_selectedImage != null) {
                          selectedAnswer = await askAI();
                          setState(() {});
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Who are You?",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : const Text("Pick An Image First"),
              const SizedBox(
                height: 25,
              ),
              selectedAnswer != null
                  ? Container(
                      color: Colors.blue[100],
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(selectedAnswer!),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("Proceed"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Text("Click on Pick an Image"),
            ],
          ),
        ),
      ),
    );
  }

  Future pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = File(returnedImage!.path);
    });
  }

  Future askAI() async {
    setState(() {
      _loading = true;
    });
    final imageAsBytes = await _selectedImage!.readAsBytes();
    final prompt = TextPart(
        "Consider the main object in this image as yourself ,now tell something about yourself");
    final imagePart = [DataPart('image/jpeg', imageAsBytes)];
    final response = await model.generateContent([
      Content.multi([prompt, ...imagePart])
    ]);

    setState(() {
      _loading = false;
    });

    return response.text;
  }
}
