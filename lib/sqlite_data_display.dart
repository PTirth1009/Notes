import 'package:flutter/material.dart';

import 'databasehelper/databasehelper.dart';

class sqlitedatadisplay extends StatefulWidget {
  const sqlitedatadisplay({Key? key}) : super(key: key);

  @override
  State<sqlitedatadisplay> createState() => _sqlitedatadisplayState();
}

class _sqlitedatadisplayState extends State<sqlitedatadisplay> {

  List<Map<String, dynamic>> myData = [];

  bool _isLoading = true;



  void _refreshData() async {
    final data = await DatabaseHelper.getItems();
    setState(() {
      myData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sqlite Database '),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : myData.isEmpty?const Center(child:  Text("No Data Available!!!")):  ListView.builder(
        itemCount: myData.length,
        itemBuilder: (context, index) => Card(

          margin: const EdgeInsets.all(15),
          child:ListTile(
              title: Text(myData[index]['title']),
              subtitle: Text(myData[index]['description']),

          ),
        ),
      ),

    );
  }
}
