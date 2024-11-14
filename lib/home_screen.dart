import 'package:flutter/material.dart';
import 'package:sample_app/M3UParser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submit() async {
    String url = _controller.text;

    if (url.isNotEmpty) {
      try {
        final parser = M3UParser();
        parser.parseM3U(url);
      }
      catch (e) {
        print(e);
      }
    }
    else {
      print ("enter url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IPTV Test"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'M3U Url'
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit'),
            )
          ],
        ),
        ),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

