import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:text_regnization/screens/result_screen.dart';
import 'package:text_regnization/screens/splash.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
    statusBarIconBrightness: Brightness.light, // dark text for status bar icons
  ));
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Text Recognition',
        theme: ThemeData(
          fontFamily: 'Poppins',
        ),
        home: SplashScreen()
        // const MainScreen(),
        );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// Add the WidgetsBindingObserver mixin
class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  final textRecognizer = TextRecognizer();
  late final Future<void> _future;

  // Add this controller to be able to control de camera
  CameraController? _cameraController;
  bool isloading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
  }

  // We should stop the camera once this widget is disposed
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  // Starts and stops the camera according to the lifecycle of the app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  Future<void> _scanImage() async {
    setState(() {
      isloading = true;
    });
    if (_cameraController == null) return;
    setState(() {
      isloading = false;
    });
    final navigator = Navigator.of(context);

    try {
      setState(() {
        isloading = true;
      });
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);
      setState(() {
        isloading = false;
      });
      await navigator.push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ResultScreen(text: recognizedText.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            // Show the camera feed behind everything
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initCameraController(snapshot.data!);

                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                          height: MediaQuery.of(context).size.height / 1.6,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            // color: Colors.amber,
                            image: DecorationImage(
                                image: AssetImage('assets/images/scanner.png'),
                                fit: BoxFit.fill),
                            // border: Border.all(color: Colors.white),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 12, right: 12, top: 15, bottom: 15),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CameraPreview(_cameraController!)),
                          )),
                    ));
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.black,
                title: const Text(
                  'Text Recognition',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // Set the background to transparent so you can see the camera preview
              backgroundColor: _isPermissionGranted ? Colors.transparent : null,
              body: _isPermissionGranted
                  ? Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: isloading == true
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: Center(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Loading",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Image.asset(
                                        "assets/images/loading.gif",
                                        height: 20,
                                        width: 20,
                                      ),
                                    ],
                                  )),
                                )
                              : Container(
                                  height: 80,
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.only(bottom: 30.0),
                                  child: ElevatedButton(
                                    onPressed: isloading == true
                                        ? null
                                        : () {
                                            _scanImage();
                                          },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Color(0xfffa8c4eb),
                                      backgroundColor:
                                          Color(0xfffa8c4eb), // Text color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12.0), // Rounded corners
                                      ),
                                    ),
                                    child: const Text(
                                      'Scan text',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                        child: const Text(
                          'Camera permission denied',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) {
      return;
    }
    setState(() {});
  }
}
