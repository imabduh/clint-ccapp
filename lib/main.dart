import 'dart:async';
import 'dart:convert';
import 'package:ccapp/models/question_model.dart';
import 'package:ccapp/providers/question_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cerdas Cermat',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/soaljawaban': (context) => const Screen1(),
        '/presentasi': (context) => const Screen2(),
        '/results': (context) => const ResultsPage(
              pointTeam1: 0,
              pointTeam2: 0,
              pointTeam3: 0,
            ),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int countdown = 3;
  @override
  void initState() {
    super.initState();
  }

  void startCountdown(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          onPopInvoked: (didPop) => false,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              Future.delayed(const Duration(seconds: 1), () {
                if (countdown > 1) {
                  setState(() {
                    countdown--;
                  });
                } else {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/presentasi');
                }
              });

              return AlertDialog(
                backgroundColor: Colors.transparent,
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "BERSIAPLAH",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Text(
                      countdown.toString(),
                      style: TextStyle(fontSize: 60, color: Colors.teal[400]),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).then((_) {
      setState(() {
        countdown = 3;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title:
          ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Cerdas Cermat',
                style: TextStyle(
                    color: Colors.teal,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
            Image.asset(
              'assets/images/hometeam.png',
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.teal),
                ),
                onPressed: () {
                  startCountdown(context);
                },
                child: const Text(
                  'Mulai',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                    const StadiumBorder(
                      side: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/soaljawaban');
                },
                child: const Text('Soal & Jawaban',
                    style: TextStyle(color: Colors.teal)),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 30)),
          ],
        ),
      ),
    );
  }
}

class Screen1 extends StatelessWidget {
  const Screen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soal & Jawaban'),
      ),
      body: const QuestionList(),
    );
  }
}

class QuestionList extends StatelessWidget {
  const QuestionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestionProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: provider.questions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      provider.questions[index].question,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.questions[index].trueAnswer,
                          style: const TextStyle(color: Colors.green),
                        ),
                        Text(
                          provider.questions[index].falseAnswer1,
                          style: const TextStyle(color: Colors.red),
                        ),
                        Text(
                          provider.questions[index].falseAnswer2,
                          style: const TextStyle(color: Colors.red),
                        ),
                        Text(
                          provider.questions[index].falseAnswer3,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => QuestionDialog(
                                question: provider.questions[index],
                                index: index,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            provider.deleteQuestion(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const QuestionDialog(),
                );
              },
              child: const Text('Add Question'),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          ],
        );
      },
    );
  }
}

class QuestionDialog extends StatefulWidget {
  final Question? question;
  final int? index;

  const QuestionDialog({super.key, this.question, this.index});

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _trueAnswerController = TextEditingController();
  final _falseAnswerController1 = TextEditingController();
  final _falseAnswerController2 = TextEditingController();
  final _falseAnswerController3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.question != null) {
      _questionController.text = widget.question!.question;
      _trueAnswerController.text = widget.question!.trueAnswer;
      _falseAnswerController1.text = widget.question!.falseAnswer1;
      _falseAnswerController2.text = widget.question!.falseAnswer2;
      _falseAnswerController3.text = widget.question!.falseAnswer3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.question == null ? 'Add Question' : 'Edit Question'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Pertanyaan'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukan Pertanayan';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _trueAnswerController,
              decoration: const InputDecoration(labelText: 'Jawaban benar'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukan Jawaban';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _falseAnswerController1,
              decoration: const InputDecoration(labelText: 'Jawaban salah # 1'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukan Jawaban';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _falseAnswerController2,
              decoration: const InputDecoration(labelText: 'Jawaban salah # 2'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukan Jawaban';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _falseAnswerController3,
              decoration: const InputDecoration(labelText: 'Jawaban salah # 3'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukan Jawaban';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (widget.question == null) {
                Provider.of<QuestionProvider>(context, listen: false)
                    .addQuestion(
                  Question(
                    question: _questionController.text,
                    trueAnswer: _trueAnswerController.text,
                    falseAnswer1: _falseAnswerController1.text,
                    falseAnswer2: _falseAnswerController2.text,
                    falseAnswer3: _falseAnswerController3.text,
                  ),
                );
              } else {
                Provider.of<QuestionProvider>(context, listen: false)
                    .updateQuestion(
                  widget.index!,
                  Question(
                    question: _questionController.text,
                    trueAnswer: _trueAnswerController.text,
                    falseAnswer1: _falseAnswerController1.text,
                    falseAnswer2: _falseAnswerController2.text,
                    falseAnswer3: _falseAnswerController3.text,
                  ),
                );
              }
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.question == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _trueAnswerController.dispose();
    _falseAnswerController1.dispose();
    _falseAnswerController2.dispose();
    _falseAnswerController3.dispose();
    super.dispose();
  }
}

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  final PageController _pageController = PageController();
  late WebSocketChannel channel;
  Timer? _timer;
  int _remainingSeconds = 10;
  int _dataTim = 0;
  int _dataPilgan = 0;
  int pointTeam1 = 0;
  int pointTeam2 = 0;
  int pointTeam3 = 0;
  bool trigerPilgan = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    wsConnection();
  }

  void _showResultsPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          pointTeam1: pointTeam1,
          pointTeam2: pointTeam2,
          pointTeam3: pointTeam3,
        ),
      ),
    );
  }

  Future<void> wsConnection() async {
    try {
      final uri = Uri.parse('ws://192.168.4.1/ws');
      channel = WebSocketChannel.connect(uri);
      await channel.ready;
      setState(() {
        channel.stream.listen(
          (data) {
            setState(() {
              if (data.contains("tim")) {
                _dataTim = (jsonDecode(data)["tim"]);
              } else if (data.contains("pilgan")) {
                _dataPilgan = (jsonDecode(data)["pilgan"]);
                trigerPilgan = true;
              } else if (data.contains("hasil direset")) {
                print(data);
                _dataTim = 0;
                _dataPilgan = 0;
              }
            });
          },
          onError: (error) {
            print('WebSocket Error tidak konek');
            channel.sink.close(status.goingAway);
          },
        );
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _remainingSeconds = 10;
          if (_pageController.page!.toInt() <
              Provider.of<QuestionProvider>(context, listen: false)
                      .questions
                      .length -
                  1) {
            channel.sink.add('reset');
            _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
          } else {
            channel.sink.add('reset');
            _timer?.cancel();
            _showResultsPage();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Consumer<QuestionProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: provider.questions.length,
                  itemBuilder: (context, index) {
                    final randomAnswer =
                        provider.questions[index].shuffledAnswers!;

                    // logika point
                    if (_dataTim > 0 &&
                        _dataPilgan > 0 &&
                        trigerPilgan == true) {
                      if (_dataTim == 1) {
                        if (_dataPilgan == 1) {
                          // A
                          if (randomAnswer[0] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam1 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[0] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam1 -= 50;
                            trigerPilgan = false;
                          }
                        }
                        // B
                        if (_dataPilgan == 2) {
                          if (randomAnswer[1] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam1 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[1] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam1 -= 50;
                            trigerPilgan = false;
                          }
                        }
                        // C
                        if (_dataPilgan == 3) {
                          if (randomAnswer[2] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam1 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[2] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam1 -= 50;
                            trigerPilgan = false;
                          }
                        }
                        // D
                        if (_dataPilgan == 4) {
                          if (randomAnswer[3] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam1 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[3] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam1 -= 50;
                            trigerPilgan = false;
                          }
                        }
                      }
                      if (_dataTim == 2) {
                        if (_dataPilgan == 1) {
                          // A
                          if (randomAnswer[0] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam2 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[0] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam2 -= 50;
                            trigerPilgan = false;
                          }
                        }
                        // B
                        if (_dataPilgan == 2) {
                          if (randomAnswer[1] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam2 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[1] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam2 -= 50;
                            trigerPilgan = false;
                          }
                        }
                        // C
                        if (_dataPilgan == 3) {
                          if (randomAnswer[2] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam2 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[2] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam2 -= 50;
                            trigerPilgan = false;
                          }
                        }
                        // D
                        if (_dataPilgan == 4) {
                          if (randomAnswer[3] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam2 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[3] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam2 -= 50;
                            trigerPilgan = false;
                          }
                        }
                      }
                      if (_dataTim == 3) {
                        if (_dataPilgan == 1) {
                          // A
                          if (randomAnswer[0] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam3 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[0] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam3 -= 50;
                            trigerPilgan = false;
                          }
                        }
                        // B
                        if (_dataPilgan == 2) {
                          if (randomAnswer[1] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam3 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[1] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam3 -= 50;
                            trigerPilgan = false;
                          }
                        }
                        // C
                        if (_dataPilgan == 3) {
                          if (randomAnswer[2] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam3 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[2] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam3 -= 50;
                            trigerPilgan = false;
                          }
                        }
                        // D
                        if (_dataPilgan == 4) {
                          if (randomAnswer[3] ==
                              provider.questions[index].trueAnswer) {
                            pointTeam3 += 100;
                            trigerPilgan = false;
                          } else if (randomAnswer[3] !=
                              provider.questions[index].trueAnswer) {
                            pointTeam3 -= 50;
                            trigerPilgan = false;
                          }
                        }
                      }
                    } else {
                      trigerPilgan = false;
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Waktu Mundur',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.red),
                                ),
                                Text(
                                  '$_remainingSeconds',
                                  style: const TextStyle(
                                      fontSize: 50, color: Colors.red),
                                ),
                              ],
                            ),
                            Text(
                              provider.questions[index].question,
                              style: const TextStyle(
                                color: Colors.teal,
                                fontSize: 24.0,
                              ),
                            ),
                            const SizedBox(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: _dataTim == 1
                                        ? Colors.teal
                                        : Colors.transparent,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Tim A",
                                        style: TextStyle(
                                          fontSize: _dataTim == 1 ? 40 : 20,
                                          color: _dataTim == 1
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        pointTeam1.toString(),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: _dataTim == 2
                                        ? Colors.teal
                                        : Colors.transparent,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Tim B",
                                        style: TextStyle(
                                          fontSize: _dataTim == 2 ? 40 : 20,
                                          color: _dataTim == 2
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        pointTeam2.toString(),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: _dataTim == 3
                                        ? Colors.teal
                                        : Colors.transparent,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Tim C",
                                        style: TextStyle(
                                          fontSize: _dataTim == 3 ? 40 : 20,
                                          color: _dataTim == 3
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        pointTeam3.toString(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _dataPilgan == 1 &&
                                                  randomAnswer[0] ==
                                                      provider.questions[index]
                                                          .trueAnswer
                                              ? Colors.teal
                                              : _dataPilgan == 1 &&
                                                      randomAnswer[0] !=
                                                          provider
                                                              .questions[index]
                                                              .trueAnswer
                                                  ? Colors.red
                                                  : Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          "A. ${randomAnswer[0]}",
                                          style: TextStyle(
                                            fontSize:
                                                _dataPilgan == 1 ? 30 : 20,
                                            color: _dataPilgan == 1 &&
                                                    randomAnswer[0] ==
                                                        provider
                                                            .questions[index]
                                                            .trueAnswer
                                                ? Colors.teal
                                                : _dataPilgan == 1 &&
                                                        randomAnswer[0] !=
                                                            provider
                                                                .questions[
                                                                    index]
                                                                .trueAnswer
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _dataPilgan == 2 &&
                                                  randomAnswer[1] ==
                                                      provider.questions[index]
                                                          .trueAnswer
                                              ? Colors.teal
                                              : _dataPilgan == 2 &&
                                                      randomAnswer[1] !=
                                                          provider
                                                              .questions[index]
                                                              .trueAnswer
                                                  ? Colors.red
                                                  : Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          "B. ${randomAnswer[1]}",
                                          style: TextStyle(
                                            fontSize:
                                                _dataPilgan == 2 ? 30 : 20,
                                            color: _dataPilgan == 2 &&
                                                    randomAnswer[1] ==
                                                        provider
                                                            .questions[index]
                                                            .trueAnswer
                                                ? Colors.teal
                                                : _dataPilgan == 2 &&
                                                        randomAnswer[1] !=
                                                            provider
                                                                .questions[
                                                                    index]
                                                                .trueAnswer
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _dataPilgan == 3 &&
                                                  randomAnswer[2] ==
                                                      provider.questions[index]
                                                          .trueAnswer
                                              ? Colors.teal
                                              : _dataPilgan == 3 &&
                                                      randomAnswer[2] !=
                                                          provider
                                                              .questions[index]
                                                              .trueAnswer
                                                  ? Colors.red
                                                  : Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          "C. ${randomAnswer[2]}",
                                          style: TextStyle(
                                            fontSize:
                                                _dataPilgan == 3 ? 30 : 20,
                                            color: _dataPilgan == 3 &&
                                                    randomAnswer[2] ==
                                                        provider
                                                            .questions[index]
                                                            .trueAnswer
                                                ? Colors.teal
                                                : _dataPilgan == 3 &&
                                                        randomAnswer[2] !=
                                                            provider
                                                                .questions[
                                                                    index]
                                                                .trueAnswer
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _dataPilgan == 4 &&
                                                  randomAnswer[3] ==
                                                      provider.questions[index]
                                                          .trueAnswer
                                              ? Colors.teal
                                              : _dataPilgan == 4 &&
                                                      randomAnswer[3] !=
                                                          provider
                                                              .questions[index]
                                                              .trueAnswer
                                                  ? Colors.red
                                                  : Colors.grey,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          "D. ${randomAnswer[3]}",
                                          style: TextStyle(
                                            fontSize:
                                                _dataPilgan == 4 ? 30 : 20,
                                            color: _dataPilgan == 4 &&
                                                    randomAnswer[3] ==
                                                        provider
                                                            .questions[index]
                                                            .trueAnswer
                                                ? Colors.teal
                                                : _dataPilgan == 4 &&
                                                        randomAnswer[3] !=
                                                            provider
                                                                .questions[
                                                                    index]
                                                                .trueAnswer
                                                    ? Colors.red
                                                    : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_pageController.page!.toInt() > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (_pageController.page!.toInt() <
                          provider.questions.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final int pointTeam1;
  final int pointTeam2;
  final int pointTeam3;

  const ResultsPage({
    Key? key,
    required this.pointTeam1,
    required this.pointTeam2,
    required this.pointTeam3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> teams = [
      {'name': 'Tim A', 'points': pointTeam1},
      {'name': 'Tim B', 'points': pointTeam2},
      {'name': 'Tim C', 'points': pointTeam3},
    ];

    teams.sort((a, b) => b['points'].compareTo(a['points']));

    final List<Color> trophyColors = [
      Colors.red,
      Colors.orange,
      Colors.brown,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Akhir'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < teams.length; i++)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, size: 70, color: trophyColors[i]),
                    const SizedBox(width: 10),
                    Text(
                      'Juara ${i + 1}: ${teams[i]['name']}',
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'skor: ${teams[i]['points']} poin',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/');
              },
              child: const Text('Kembali ke awal'),
            ),
          ],
        ),
      ),
    );
  }
}
