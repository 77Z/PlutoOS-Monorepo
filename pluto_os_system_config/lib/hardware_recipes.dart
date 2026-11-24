import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';

class HardwareRecipes extends StatefulWidget {
  const HardwareRecipes({ super.key });

  @override
  State<StatefulWidget> createState() => HardwareRecipesState();
}

class HardwareRecipesState extends State<HardwareRecipes> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          spacing: 20,
          children: [
            /* Header bar */
            Row(
              spacing: 15,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("ACTIVE HARDWARE RECIPE", style: TextStyle(fontFamily: "UbuntuMono")),
                  Text("Generic x86_64 Machine", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30))
                ])
              ],
            ),

            /* Page Content */
            Expanded(child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Text("bruh"),
              ],
            ))
          ],
        ),
      ),
    );
  }
}