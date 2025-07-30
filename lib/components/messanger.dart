import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:govdictionary/models/word.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// showDialogMessage()
showDialogMessage(BuildContext context, Word word) {
  if (!context.mounted) return;
  Future.delayed(
    Duration.zero,
    () {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            scrollable: true,
            titleTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
            content: Column(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        await Clipboard.setData(
                            ClipboardData(text: word.correct));
                        if (!context.mounted) return;
                        showSnackBarMessage(context,
                            'সঠিক বানানটি সফলভাবে কপি হয়েছে', word.correct);
                      },
                      label: Text(word.correct),
                      icon: const Icon(
                        Icons.check_circle_outlined,
                        color: Colors.green,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        await Clipboard.setData(
                            ClipboardData(text: word.incorrect));
                        if (!context.mounted) return;
                        showSnackBarMessage(context,
                            'ভুল বানানটি সফলভাবে কপি হয়েছে', word.incorrect);
                      },
                      label: Text(word.incorrect),
                      icon: const Icon(
                        Icons.highlight_off,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            icon: TextButton.icon(
              onPressed: null,
              label: const Text("কপি করতে চাইলে ট্যাপ করুন"),
              icon: const Icon(Icons.info_outline),
            ),
            actions: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        print('Icon pressed');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () {
                        launchUrl(
                          Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.govdictionary',
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text:
                                'সঠিক বানান - ${word.correct}\nভুল বানান - ${word.incorrect}\n\nসঠিক ও ভুল বানান পেতে অ্যাপটি ডাউনলোড করুন-> https://play.google.com/store/apps/details?id=com.govdictionary'));
                        showSnackBarMessage(context, 'সফলভাবে কপি হয়েছে',
                            'সঠিক বানান - ${word.correct}\nভুল বানান - ${word.incorrect}');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text:
                                'সঠিক বানান - ${word.correct}\nভুল বানান - ${word.incorrect}\n\nসঠিক ও ভুল বানান পেতে অ্যাপটি ডাউনলোড করুন-> https://play.google.com/store/apps/details?id=com.govdictionary',
                            subject: 'সঠিক ও ভুল বানান',
                            sharePositionOrigin: Rect.fromLTWH(100, 0, 0, 100),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

// showSnackBarMessage()
showSnackBarMessage(BuildContext context, String title, String content) {
  if (!context.mounted) return;
  Future.delayed(
    Duration.zero,
    () {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ListTile(
            title: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              content,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          showCloseIcon: true,
          closeIconColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.teal, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
          backgroundColor: Colors.teal, // Changed to teal for better visibility
        ),
      );
    },
  );
}
