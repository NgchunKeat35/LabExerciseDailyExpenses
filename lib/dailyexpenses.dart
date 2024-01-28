import 'package:dailyexpenses/Controller/request_controller.dart';
import 'package:dailyexpenses/Model/expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DailyExpensesApp());
}

class DailyExpensesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExpenseList(),
    );
  }
}

class ExpenseList extends StatefulWidget
{
  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final List<Expense> expenses = [];
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  double totalAmount =0;

  void _addExpense() async {
    String description = descController.text.trim();
    String amount = amountController.text.trim();
    if (amount.isNotEmpty && amount.isNotEmpty) {
      Expense exp =
        Expense(double.parse(amount),description,txtDateController.text);
      if(await exp.save()){
          setState((){
          expenses.add(exp);
          descController.clear();
          amountController.clear();
          calculateTotal();
          });
        }else{
    _showMessage("Failed to save Expenses data");
      }
    }
  }
  void calculateTotal(){
    totalAmount = 0;
    for (Expense ex in expenses){
      totalAmount += ex.amount;
    }
    totalAmountController.text = totalAmount.toString();
  }

  void _removeExpense(int index) {
   totalAmount -= expenses[index].amount;
   setState(() {
     expenses.removeAt(index);
     totalAmountController.text =totalAmount.toString();
   });
  }

  void _showMessage(String msg) {
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:Text(msg),
          ),
      );
    }
  }

 void _editExpense(int index){
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditExpenseScreen(
              expense: expenses[index],
              onSave: (editedExpense){
                setState(() {
                  totalAmount += editedExpense.amount - expenses[index].amount;
                  expenses[index] = editedExpense;
                  totalAmountController.text = totalAmount.toString();
                });
              },
          ),
      ),
    );
 }
  _selectDate()async{
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
    );
    if (pickedDate != null && pickedTime != null){
      setState(() {
        txtDateController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"
            "${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
 }

 @override

 void iniState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      _showMessage("Welcome");
      RequestController req = RequestController(
          path: "/api/timezone/Asia/Kuala_Lumpur",
          server: "http://worldtimeapi.org");
      req.get().then((value){
        dynamic res = req.result();
        txtDateController.text =
            res["datetime"].toString().substring(0,19).replaceAll('T','');
      });
     expenses.addAll(await Expense.loadAll());
     setState(() {
       calculateTotal();
     });
    });
 }
  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          //Unique key for each item
          return Dismissible(
            key: Key(expenses[index].amount.toString()), //Unique key for each item
            background: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            onDismissed: (direction){
              //handle item removal here
              _removeExpense(index);
              ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Item dismissed')));
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(expenses[index].desc),
                subtitle :Row(children: [
                  Text('Amount:${expenses[index].amount}'),
                  const Spacer(),
                  Text('Data:${expenses[index].dateTime}')
                ]),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeExpense(index),
                ),
                onLongPress: (){
                  _editEpense(index);

                },
              ),

            )

          );
        },
      ),
    );
  }

  void _editEpense(int index) {
    double totalAmount = 0;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditExpenseScreen(
                expense: expenses[index],
                onSave: (editedExpense){
                  setState(() {
                    totalAmount += (editedExpense.amount) - (expenses[index].amount);
                    expenses[index]=editedExpense;
                  });
                },
            ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                  labelText: 'Amount (RM)'
              ),
            ) ,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: totalAmountController,
              readOnly: true,
              decoration: InputDecoration(
                  labelText: 'Total Spend (RM):'
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              onTap: ()
              async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedDate != null && pickedTime != null){
                  //setState(()
                  {
                    txtDateController.text =
                    "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"
                        "${pickedTime.hour}:${pickedTime.minute}:00";
                  };
                }
              },
              decoration: const InputDecoration(labelText: 'Date'),
            ),
          ),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text('Add Expense'),
          ),
          Container(
            child: _buildListView(),
          )
        ],
      ),
    );
  }
}
class EditExpenseScreen extends StatelessWidget {
  final Expense expense;
  final Function(Expense) onSave;

  EditExpenseScreen({required this.expense, required this.onSave});

  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    descController.text = expense.desc;
    amountController.text = expense.amount.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              onTap: ()
              async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedDate != null && pickedTime != null){
                  //setState(()
                  {
                    txtDateController.text =
                    "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}"
                        "${pickedTime.hour}:${pickedTime.minute}:00";
                  };
                }
              },
              decoration: const InputDecoration(labelText: 'Date'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: totalAmountController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Total Spend (RM):'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(Expense(double.parse(amountController.text),
                descController.text,expense.dateTime));
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
