import 'package:flutter/material.dart';
import 'package:govdictionary/models/word.dart';

// showDialogMessage()
showDialogMessage(BuildContext context, Word word) {
  Future.delayed(
    Duration.zero,
    () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // scrollable: true,
            // title: Text(title),
            titleTextStyle: const TextStyle(fontSize: 16, color: Colors.black),
            content: Text('${word.correct}\n${word.incorrect}'),
            // iconColor:  ,
            icon: const Icon(Icons.notifications),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: IconButton(
                      color: Colors.green,
                      onPressed: () {
                        showSnackBarMessage(
                            context, "Success", "Record Deleted");
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check_circle_outlined),
                    ),
                  ),
                  Flexible(
                    child: IconButton(
                      color: Colors.red,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.highlight_off),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      );
    },
  );
}

// showSnackBarMessage()
showSnackBarMessage(BuildContext context, String title, String content) {
  Future.delayed(
    Duration.zero,
    () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ListTile(
            // tileColor: Colors.white,
            title: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              content,
              style: const TextStyle(color: Colors.white),
            ),
            // subtitleTextStyle: const TextStyle(color: Colors.white),
          ),
          showCloseIcon: true,
          closeIconColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          backgroundColor: Colors.black87,
          // backgroundColor: Colors.black87,
          action: SnackBarAction(
            label: "Undo",
            onPressed: () {
              print("Pressed Undo");
            },
          ),
        ),
      );
    },
  );
}
