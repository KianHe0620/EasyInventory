import 'package:easyinventory/views/suppliers/suppliers.dart';
import 'package:easyinventory/views/utils/global.colors.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:SingleChildScrollView(
          child:Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Title
                const Text('Dashboard',
                style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold)),
                SizedBox(height: 30),

                //Profit Card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    elevation: 2,
                    color: GlobalColors.textFieldColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text("Today's Profit"),
                          SizedBox(height: 10),
                          //Retrieve the data from database
                          Text(
                            "RM1000.00",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ),

                //Row of buttons
                Row(
                  children: [

                    //Suppliers Button
                    Expanded(
                      child: Card(
                        color: GlobalColors.textFieldColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => const SuppliersPage())
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: const [
                                Icon(Icons.group, size: 40),
                                SizedBox(height: 8),
                                Text("Suppliers")
                              ],
                            ),
                          ),
                        )
                      )
                    ),
                    const SizedBox(height: 12),

                    //Report Button
                    Expanded(
                      child: Card(
                        color: GlobalColors.textFieldColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: (){
                            //Navigate to Report page
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: const [
                                Icon(Icons.bar_chart, size: 40),
                                SizedBox(height: 8),
                                Text("Report")
                              ],
                            ),
                          ),
                        )
                      )
                    ),
                  ],
                )
              ]
            )
          )
        )
      )
    );
  }
}