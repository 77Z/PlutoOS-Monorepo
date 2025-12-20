import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plutoos_system_library/plutoos_system_library.dart';
import 'package:yaru/yaru.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({ super.key });

  @override
  State<StatefulWidget> createState() => StoragePageState();
}

class StoragePageState extends State<StoragePage> {
  String userDesiredSwapSize = "";

  void refreshSwapProperties() {
    if (!PlutoosSystemLibrary.isSwapEnabled()) {
      setState(() => userDesiredSwapSize = "0");
      return;
    }

    setState(() => userDesiredSwapSize = PlutoosSystemLibrary.getSwapSizeInGiB().toString());
  }

  @override
  void initState() {
    super.initState();

    refreshSwapProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Storage breakup bar

          // Swap
          Card(
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              onTap: () {
                refreshSwapProperties();
                showDialog(context: context, builder: (BuildContext context) => StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text("Swap Configuration"),
                      content: SizedBox(
                        height: 200,
                        width: 400,
                        child: Column(
                          spacing: 10,
                          children: [
                            YaruInfoBox(
                              yaruInfoType: YaruInfoType.information,
                              child: const Text("At the moment, this swap can only be used as memory fallback and not to hibernate the system."),
                            ),
                            Row(
                              spacing: 5,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Swap size"),
                                    Text("set 0 to disable", style: TextStyle(color: Colors.grey),),
                                  ],
                                ),
                                Spacer(),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.end,
                                    controller: TextEditingController(text: userDesiredSwapSize)..selection = TextSelection.fromPosition(TextPosition(offset: userDesiredSwapSize.length)),
                                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                    onChanged: (v) => setState(() => userDesiredSwapSize = v),
                                  ),
                                ),
                                const Text("GiB")
                              ],
                            )
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, "Cancel"), child: const Text("Cancel")),
                        ElevatedButton(onPressed: double.tryParse(userDesiredSwapSize) == null ? null : () {
                          PlutoosSystemLibrary.setupSwap(double.parse(userDesiredSwapSize));
                          Navigator.pop(context);
                        }, child: const Text("Apply"))
                      ],
                    );
                  }));
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Text("System Swap"),
                    Text(" · $userDesiredSwapSize GiB", style: TextStyle(fontFamily: "UbuntuMono")),
                    Spacer(),
                    Icon(YaruIcons.forward)
                  ],
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}