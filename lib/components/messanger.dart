import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:govdictionary/models/word.dart';
import 'package:share_plus/share_plus.dart';

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
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    await Clipboard.setData(ClipboardData(text: word.correct));
                    if (!context.mounted) return;
                    showSnackBarMessage(
                        context, 'Copied successfully', word.correct);
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
                    showSnackBarMessage(
                        context, 'Copied successfully', word.incorrect);
                  },
                  label: Text(word.incorrect),
                  icon: const Icon(
                    Icons.highlight_off,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            icon: TextButton.icon(
              onPressed: null,
              label: const Text("কপি করতে চাইলে ট্যাপ করুন"),
              icon: const Icon(Icons.info_outline),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text:
                          'শুদ্ধ - ${word.correct}\n\nঅশুদ্ধ - ${word.incorrect}',
                      subject: 'শুদ্ধ ও অশুদ্ধ শব্দ',
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
            borderRadius: BorderRadius.circular(2),
          ),
          backgroundColor: Colors.black26,
        ),
      );
    },
  );
}
