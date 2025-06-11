import 'package:flutter/material.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';

Future<dynamic> CustomDialog({required String message, context}) {
  return showDialog(
    context: context,
    builder:
        (context) => Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(message),
                SizedBox(height: 30),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        fixedSize: Size(110, 40),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Dismiss',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        fixedSize: Size(110, 40),
                      ),
                      onPressed: () {
                        showSnackbar(context, 'Done');
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Download',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}
