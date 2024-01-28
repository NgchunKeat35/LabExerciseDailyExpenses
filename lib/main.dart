 import 'package:flutter/material.dart';

void main () => runApp(const MyApp());

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    const title = 'Daily Expenses';

    return MaterialApp(
      title: title,
      home:Scaffold(
        appBar:AppBar(
          title: const Text(title),
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Groceries - \Rm150.00'),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title:Text('clothing - \Rm39.00'),
            ),
            ListTile(
              leading: Icon(Icons.local_dining),
              title: Text('Dinner - \Rm7.00'),
            ),
          ],
        ),
      ),
    );
  }
}
 class Expense {
   final String description;
   final String amount;

   Expense(this.description,this.amount);
 }

 class DailyExpensesApp extends StatelessWidget{
   @override
   Widget build(BuildContext context){
     return  MaterialApp(
       home: ExpenseList(),
     );
   }
 }

 class ExpenseList extends StatefulWidget{
   @override
   _ExpenseListState createState() => _ExpenseListState();

 }

 class _ExpenseListState extends State<ExpenseList> {
   final List<Expense>expenses = [];
   final TextEditingController descriptionController = TextEditingController();
   final TextEditingController amountController =  TextEditingController();

   void _addExpense(){
     String description = descriptionController.text.trim();
     String amount = amountController.text.trim();
     if (description.isNotEmpty && amount.isNotEmpty){
       setState(() {
         expenses.add(Expense(description, amount));
         descriptionController.clear();
         amountController.clear();
       });
     }
   }
   void _removeExpense(int index){
     setState(() {
       expenses.removeAt(index);
     });
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text('Daily Expenses'),
       ),
       body: Column(
         children: [
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: TextField(
               controller:descriptionController,
               decoration: InputDecoration(
                 labelText: 'Description',
               ),
             ),
           ),
           ElevatedButton(
             onPressed: _addExpense,
             child: Text('Add Expense'),
           ),
           Container(
             child: _buildListView(),
           ),
         ],
       ),
     );
   }
   Widget _buildListView(){
     return Expanded(
       child: ListView.builder(
         itemCount:expenses.length,
         itemBuilder:(context, index){
           return Card(
             margin: EdgeInsets.all(8.0),
             child: ListTile(
               title:Text(expenses[index].description),
               subtitle: Text('Amount:${expenses[index].amount}'),
               trailing: IconButton(
                 icon: Icon(Icons.delete),
                 onPressed: ()=>_removeExpense(index),
               ),
             ),
           );
         } ,
       ),
     );
   }
 }
