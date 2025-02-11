import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:mboathoscope/controller/appDirectorySingleton.dart';
import 'package:mboathoscope/controller/helpers.dart';
import 'package:mboathoscope/views/widgets/alert_dialog_model.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class headerHalf extends StatefulWidget {
  const headerHalf({Key? key}) : super(key: key);

  @override
  State<headerHalf> createState() => _headerHalfState();
}

class _headerHalfState extends State<headerHalf> {
  late final RecorderController recorderController;
  bool isRecordingCompleted = false;

  ///for time to determine whether to save or delete
  bool isRecording = false;

  ///for time to determine whether to show microphone or not
  late String path;
  static Directory appDirectory = AppDirectorySingleton().appDirectory;
  AppDirectorySingleton appDirectorySingleton = AppDirectorySingleton();
  String heartBeatFileFolderPath = AppDirectorySingleton.heartBeatParentPath;

  @override
  void initState() {
    _initialiseController();
    super.initState();
  }

  ///Initializes Recorder
  void _initialiseController() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;
  }

  ///
  Widget recordBody() {

    if (isRecording) {
      ///recorderController.isRecording: could have used this but issuing stoprecorder doesn't change it state, will investigate why it doesn't refresh
      return InkWell(
        onTap: () {
          ///For Start or Stop Recording
          _startOrStopRecording();
        },
        child: SafeArea(

          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: RippleAnimation(
                repeat: true,
                color: const Color(0xff3D79FD),
                minRadius: 65,
                ripplesCount: 6,
                child: const CircleAvatar(
                  maxRadius: 65.0,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(
                    Icons.stop,
                    color: Colors.white,
                    size: 70.0,
                  ),
                ),
              )

              // AudioWaveforms(              // ASK..

              //   enableGesture: false,
              //   size: Size(MediaQuery.of(context).size.width / 2, 50),
              //   recorderController: recorderController,
              //   waveStyle: const WaveStyle(waveColor: Color.fromARGB(255, 161, 14, 14), extendWaveform: true, showMiddleLine: false,
              //       durationStyle: TextStyle(color: Colors.black), showDurationLabel: true,
              //       durationLinesColor: Colors.transparent),
              //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: helpers.appBlueColor,),
              //   padding: const EdgeInsets.only(left: 18),
              //   margin: const EdgeInsets.symmetric(horizontal: 15),
              // )

              ),
        ),
      );
    } else {
      ///Applies when recording is completed and saved or start of the page
      return InkWell(
        child: CircleAvatar(
          maxRadius: 80.0,
          backgroundColor: Colors.white,
          child: Image.asset(
            'assets/images/img_record.png',
            height: 150,
            width: 150,
          ),
        ),
        onTap: () {
          ///Start or Stop Recording
          _startOrStopRecording();
        },
      );

      // Container(                           // ASK..
      //   height: 140,
      //   width: 140,
      //   decoration: BoxDecoration(
      //     color: helpers.appBlueColor,
      //     shape: BoxShape.circle,
      //   ),
      //   child: IconButton(
      //     icon: const Icon(Icons.mic),
      //     iconSize: 100,
      //     color: Colors.white,
      //     onPressed: () {
      //       ///Start or Stop Recording
      //       _startOrStopRecording();
      //     },
      //   ),
      // );
    }
  }

  ///Starts and Stops Recorder
  _startOrStopRecording() async {
    ///
    helpers().checkForMicrophonePermission(recorderController);

    try {
      if (recorderController.isRecording) {
        recorderController.reset();

        ///Stops recording and returns path,
        ///saves file automatically here
        recorderController.stop(false).then((value) async {
          DialogUtils.showCustomDialog(context, title: 'title', path: path);
        });

        ///Remove because rename and delete functions have a bug
        ///This allows UI to switch to allow user to either save or delete, also allow for rename
        setState(() {
          isRecording = !isRecording;
          // isRecordingCompleted = true;
        });
      } else {
        ///States paths for recording to be saved
        path =
            "${appDirectory.path}/$heartBeatFileFolderPath${DateTime.now().millisecondsSinceEpoch}.mpeg4";

        await recorderController.record(path: path);

        /// refresh state for changes on page to reflect
        setState(() {
          isRecording = !isRecording;
        });
      }
    } catch (error) {
      debugPrint(error.toString());
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 34.0, left: 20, right: 30),
          child: Row(
            children: <Widget>[

              Expanded(
                flex: 5,
                child: Image.asset(
                  'assets/images/img_head.png',
                  height: 80,
                  width: 80,
                ),
              ),

              const SizedBox(
                width: 150,
              ),
              
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Image.asset(
                          'assets/images/img_notiblack.png',
                          height: 35,
                          width: 32,
                          color: const Color(0xff3D79FD),
                        ),
                      ),
                      
                      const Positioned(
                        bottom: 0.02,
                        right: 3,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xff3D79FD),
                          foregroundColor: Colors.white,
                        ), //CircularAvatar
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        Padding(
          padding: const EdgeInsets.only(
            right: 8.0,
            left: 8.0,
            top: 20.0,
            bottom: 20.0,
          ),

          child: Row(
            children: <Widget>[

              // Expanded(                  // ASK --> heart & lung switch
              //   flex: 1,
              //   //padding: const EdgeInsets.only(left: 2.0, right: 2.0),
              //   child: Stack(
              //     children: [
              //       Container(
              //         alignment: Alignment.center,
              //         child: Image.asset(
              //           'assets/images/img_round.png',
              //           height: 80,
              //           width: 80,
              //         ),
              //       ),
              //       Container(
              //         alignment: Alignment.center,
              //         child: Padding(
              //           padding: const EdgeInsets.only(top: 18.0),
              //           child: Column(
              //             children: [
              //               Image.asset(
              //                 'assets/images/img_heart.png',
              //                 height: 20,
              //                 width: 20,
              //               ),
              //               const Text(
              //                 'heart',
              //                 style: TextStyle(
              //                   fontSize: 12,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                    left: 8.0,
                    top: 20.0,
                    bottom: 7.0,
                  ),
                  child: recordBody(),
                ),
              )
            ],
          ),
        ),

      

        // Consumer<AppDirectorySingleton>(           // ASK..
        //   builder: (context, appDirSingleton, child) {
        //     return Text(
        //         'Total count: ${appDirSingleton.heartbeatAndPathMap.entries.length}');
        //   },
        // ),

        const Text(
          'Press and hold the button to transmit the sound',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
          ),
        ),
        const Padding(
          padding:
              EdgeInsets.only(top: 10.0, bottom: 8.0, left: 35.0, right: 35.0),
          child: Text(
            'Please ensure that you are wearing noise cancelling headphones',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 18.0, top: 17.0),
              child: Text(
                'Recordings',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
