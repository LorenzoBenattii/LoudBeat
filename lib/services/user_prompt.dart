import 'package:flutter/material.dart';

class UserPromptService {
  Future<String> askText(BuildContext context, String text) async {
    final controller = TextEditingController();

    final result = await showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text(text),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              }, 
              child: const Text("OK"))
          ],
        );
      }
    );
      
    return result ?? "";
  }
}


final userPromptService = UserPromptService();


