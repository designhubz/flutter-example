import 'package:flutter/material.dart';
import 'package:try_on_example/ccl_tryon_demo_page.dart';
import 'package:try_on_example/eyewear_tryon_demo_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(home: HomePage()),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DesignHubz TryOn Example"),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 250,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) {
                        return const EyewearTryOnDemoPage();
                      }));
                    },
                    child: const Text("Eyewear Demo")),
              ),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) {
                        return const CCLTryOnDemoPage();
                      }));
                    },
                    child: const Text("CCL Demo")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
