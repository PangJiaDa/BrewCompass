import 'package:coffee_app/styles.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

//TODO: floating action button for add steps, random key generator

class EditSteps extends StatefulWidget {
  EditSteps(this.steps);
  List<StepData> steps;

  @override
  _EditStepsState createState() => _EditStepsState();
}

class _EditStepsState extends State<EditSteps> {
  List<StepData> currentSteps = [];
  var uuid = new Uuid();

  @override
  void initState() {
    super.initState();
    currentSteps = widget.steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('edit your steps'),
        leading: BackButton(
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: currentSteps.length,
          itemBuilder: (context, index) {
            final currentNum = index + 1;
            String currentEntry = currentSteps[index].indivStep;
            return Column(
              children: <Widget>[
                Dismissible(
                  background: Container(
                    color: Colors.red,
                  ),
                  key: Key(currentSteps[index].id),
                  child: ListTile(
                      leading: Text(currentNum.toString()),
                      title: Text(currentSteps[index].indivStep),
                      trailing: MaterialButton(
                        child: Icon(Icons.edit),
                        onPressed: () {
                          // TODO: editing of text class
                          _editTextDialog(currentEntry, index);
                        },
                      )),
                  onDismissed: (direction) {
                    removeStep(index);
                  },
                ),
                Divider(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("Add Step"),
        onPressed: () {
          setState(() {
            StepData temp =
                new StepData(indivStep: "Enter steps", id: uuid.v4());
            currentSteps.add(temp);
            _editTextDialog(
                temp.indivStep, currentSteps.indexOf(currentSteps.last));
          });
        },
      ),
    );
  }

  void removeStep(int index) {
    setState(() {
      currentSteps.removeAt(index);
    });
  }

  void _editTextDialog(String currentEntry, int index) {
    final _formKey = GlobalKey<FormState>();
    String newEntry = currentEntry;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Edit Step"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: currentEntry,
                    keyboardType: TextInputType.multiline,
                    onSaved: (value) => newEntry = value,
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                        color: Colors.blue[200],
                        child: Icon(Icons.check_circle_outline),
                        onPressed: () {
                          _formKey.currentState.save();
                          setState(() {
                            currentSteps[index].indivStep = newEntry;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      Divider(),
                      cancelButton(context),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget cancelButton(BuildContext context) {
    return MaterialButton(
      color: Colors.red[400],
      child: Icon(Icons.close),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}

class StepData {
  String id;
  String indivStep;

  StepData({this.id, this.indivStep});

  List<String> convertToListOfStrings(List<StepData> stepDataList) {
    // List<String> result = [];
    // for (int i = 0; i < stepDataList.length; ++i) {
    //   result.add(stepDataList[i].indivStep);
    // }
    // return result;
    return stepDataList.map((x) => x.indivStep).toList();
  }
}

/**
 *  int currentStep = 0;
  bool complete = false;

  List<Step> steps1 = [
    Step(
      title: Text("step"),
      isActive: true,
      state: StepState.complete,
      content: Column(
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            decoration: InputDecoration(
                hintText: "Enter your step", hintStyle: Styles.createEntryText),
          )
        ],
      ),
    ),
    Step(
      isActive: false,
      state: StepState.complete,
      title: Text("step"),
      content: Column(
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            decoration: InputDecoration(
                hintText: "Enter your step", hintStyle: Styles.createEntryText),
          )
        ],
      ),
    )
  ];


 next() {
    if(currentStep + 1 != steps1.length) {
      goTo(currentStep +1);
    } else {
      setState(() {
        complete = true;
      });
    }
   
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

   goTo(int step) {
    setState(() {
      currentStep = step;
    });
  }

  Step singleStep = Step(
    title: Text("step"),
    content: Column(
      children: <Widget>[
        TextFormField(
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          decoration: InputDecoration(
              hintText: "Enter your step", hintStyle: Styles.createEntryText),
        )
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('edit your steps'),
        leading: BackButton(
          color: Colors.black,
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stepper(
              steps: steps1,
              currentStep: currentStep,
              onStepContinue: next(),
              onStepCancel: cancel,
               onStepTapped: (step) => goTo(step),
            ),
          ),
        ],
      ),
    );
  }

  List<Step> _buildStep() {}
}
 */
