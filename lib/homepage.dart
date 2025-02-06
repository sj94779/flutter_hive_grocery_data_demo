import 'package:flutter/material.dart';

import 'package:hive/hive.dart';

import 'data_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //textfield controllers
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  //form key
  final formGlobalKey = GlobalKey<FormState>();
  var box;

  var items = [];
  var selectedValue;
  var metrics = ["kg", "ltr", "gram", "dozen", "nos"];

  void getItems() async {
    box = await Hive.openBox('hive_box'); // open box

    setState(() {
      items = box.values
          .toList()
          .reversed
          .toList(); //reversed so as to keep the new data to the top
    });
  }

  @override
  void initState() {
    super.initState();

    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grocessories Memo")),
      body: items.length == 0 //check if the data is present or not
          ? const Center(child: Text("No Data"))
          : ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (_, index) {
            return Card(
              child: ListTile(
                title: Text(items[index].item!),
                subtitle: Row(
                  children: [
                    Text(items[index].quantity.toString()),
                    const SizedBox(width: 5),
                    Text(items[index].metrics.toString())
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //edit icon
                    IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                        print("key is : ${items[index].key}");
                            _showForm(context, items[index].key, index);})
                        ,
                    // Delete button
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          box = await Hive.openBox('hive_box');
                          box.delete(items[index].key);
                          getItems();
                        }),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(context, null, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext ctx, var itemKey, var index) {
    if (itemKey != null) {
      _itemController.text = items[index].item;
      _qtyController.text = items[index].quantity.toString();
      selectedValue = items[index].metrics;
    }
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        isScrollControlled: true,
        builder: (_) => Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 15,
                left: 15,
                right: 15),
            child: Form(
              key: formGlobalKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _itemController,
                    validator: (value) {
                      if (value!.isEmpty) return "Required Field";
                      return null;
                    },
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _qtyController,
                    validator: (value) {
                      if (value!.isEmpty) return "Required Field";
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Quantity'),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(0.0),
                        ),
                      ),
                    ),
                    hint: const Text("Select Metrics"),
                    value: selectedValue,
                    onChanged: (newValue) {
                      setState(() {
                        selectedValue = newValue;
                      });
                    },
                    validator: (newValue) {
                      if (selectedValue == null) return "Field is empty";
                      return null;
                    },
                    items: metrics.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Exit")),
                      ElevatedButton(
                        onPressed: () async {
                          if (formGlobalKey.currentState!.validate()) {
                            box = await Hive.openBox('hive_box');
                            DataModel dataModel = DataModel(
                                item: _itemController.text,
                                quantity: int.parse(_qtyController.text),
                                metrics: selectedValue);
                            if (itemKey == null) {
                              //if the itemKey is null it means we are creating new data
                              setState(() {
                                _itemController.text = "";
                                _qtyController.text = "";
                                selectedValue = null;
                              });

                              box.add(dataModel);
                              Navigator.of(context).pop();
                            } else {
                              //if itemKey is present we update the data
                              box.put(itemKey, dataModel);
                              Navigator.of(context).pop();
                            }

                            setState(() {
                              _itemController.clear();
                              _qtyController.clear();
                              selectedValue = null;
                            });
                            //to get refreshedData
                            getItems();
                          }
                          // Close the bottom sheet
                        },
                        child: Text(itemKey == null ? 'Create New' : 'Update'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
            )));
  }
}