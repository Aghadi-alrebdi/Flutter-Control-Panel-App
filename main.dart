import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Arm Control Panel',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RobotArmControlPage(),
    );
  }
}

class RobotArmControlPage extends StatefulWidget {
  @override
  _RobotArmControlPageState createState() => _RobotArmControlPageState();
}

class _RobotArmControlPageState extends State<RobotArmControlPage> {
  double servo1 = 90, servo2 = 90, servo3 = 90, servo4 = 90;
  List<Map<String, dynamic>> savedPoses = [];

  final String baseUrl = 'http://10.0.2.2/flutter_robot_control_panel';

  Future<void> savePose() async {
    final response = await http.post(
      Uri.parse('$baseUrl/save_pose.php'),
      body: {
        'servo1': servo1.toString(),
        'servo2': servo2.toString(),
        'servo3': servo3.toString(),
        'servo4': servo4.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('Pose saved: ${response.body}');
      fetchSavedPoses();
    } else {
      print('Failed to save pose');
    }
  }

  Future<void> fetchSavedPoses() async {
    final response = await http.get(Uri.parse('$baseUrl/get_pose.php'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        savedPoses = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print('Failed to fetch poses');
    }
  }

  Future<void> runPose(List<double> pose) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_status.php'),
      body: {
        'servo1': pose[0].toInt().toString(),
        'servo2': pose[1].toInt().toString(),
        'servo3': pose[2].toInt().toString(),
        'servo4': pose[3].toInt().toString(),
      },
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      if (res['success'] == true) {
        print('Run pose saved successfully');
      } else {
        print('Failed to save run pose: ${res['error']}');
      }
    } else {
      print('HTTP error on run pose: ${response.statusCode}');
    }
  }

  Future<void> deletePose(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/remove_pose.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      if (resp['success'] == true) {
        print('Pose deleted successfully');
        fetchSavedPoses();
      } else {
        print('Delete failed: ${resp['error']}');
      }
    } else {
      print('Delete request failed with status: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSavedPoses();
  }

  Widget buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(label)),
        Expanded(
          flex: 5,
          child: Slider(
            value: value,
            min: 0,
            max: 180,
            divisions: 180,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 8),
        Text(value.round().toString()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Robot Arm Panel Control')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSlider('Motor 1', servo1, (val) => setState(() => servo1 = val)),
              buildSlider('Motor 2', servo2, (val) => setState(() => servo2 = val)),
              buildSlider('Motor 3', servo3, (val) => setState(() => servo3 = val)),
              buildSlider('Motor 4', servo4, (val) => setState(() => servo4 = val)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {
                      servo1 = servo2 = servo3 = servo4 = 90;
                    }),
                    child: Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: savePose,
                    child: Text('Save Pose'),
                  ),
                  ElevatedButton(
                    onPressed: () => runPose([servo1, servo2, servo3, servo4]),
                    child: Text('Run'),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text('Saved Poses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Divider(),
              ...savedPoses.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final pose = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(
                      'Pose $index: ${pose['servo1']}, ${pose['servo2']}, ${pose['servo3']}, ${pose['servo4']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () {
                            setState(() {
                              servo1 = double.parse(pose['servo1'].toString());
                              servo2 = double.parse(pose['servo2'].toString());
                              servo3 = double.parse(pose['servo3'].toString());
                              servo4 = double.parse(pose['servo4'].toString());
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deletePose(pose['id'].toString()),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
