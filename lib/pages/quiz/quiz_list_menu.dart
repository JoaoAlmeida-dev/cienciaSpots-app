import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iscte_spots/pages/quiz/quiz_page.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_back_button.dart';
import 'package:iscte_spots/widgets/my_app_bar.dart';
import 'package:iscte_spots/widgets/network/error.dart';

import '../../services/quiz/quiz_service.dart';
import '../../widgets/dialogs/CustomDialogs.dart';

//const API_ADDRESS = "http://192.168.1.124";

//const API_ADDRESS_PROD = "https://194.210.120.48";
//const API_ADDRESS_TEST = "http://192.168.1.124";
const MAX_TRIALS = 3;

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

// FOR ISOLATED TESTING
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: QuizMenu()));
}

class QuizMenu extends StatelessWidget {
  static const String pageRoute = "/quiz_menu";
  static const IconData icon = Icons.help;

  const QuizMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.quizPageTitle,
        leading: const DynamicBackIconButton(),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: const QuizList(),
      ),
    );
  }
}

class QuizList extends StatefulWidget {
  const QuizList({Key? key}) : super(key: key);

  @override
  _QuizListState createState() => _QuizListState();
}

class _QuizListState extends State<QuizList> {
  final fetchFunction = QuizService.getQuizList;
  late Future<List<dynamic>> futureQuizList;
  bool isLoading = false;

  bool isTrialLoading = false;

  @override
  void initState() {
    super.initState();
    futureQuizList = fetchFunction();
  }

  startTrial(int quizNumber) async {
    isTrialLoading = true;
    try {
      Map newTrialInfo = await QuizService.startTrial(quizNumber);
      isTrialLoading = false;

      int newTrialNumber = newTrialInfo["trial_number"];
      if (mounted) {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => QuizPage(
                      quizNumber: quizNumber,
                      trialNumber: newTrialNumber,
                    )))
            .then((value) {
          setState(() {
            futureQuizList = fetchFunction();
          });
        });
      }
    } catch (e) {
      setState(() {
        isTrialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isTrialLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(AppLocalizations.of(context)!.quizGenerating),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              SizedBox(
                // Container to hold the description
                height: 50,
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.quizAvailable,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: futureQuizList,
                  builder: (context, snapshot) {
                    List<Widget> children;
                    if (snapshot.hasData) {
                      var items = snapshot.data as List<dynamic>;
                      return RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            if (!isLoading) {
                              futureQuizList = fetchFunction();
                            }
                          });
                        },
                        child: items.isEmpty
                            ? Center(
                                child: Text(AppLocalizations.of(context)!
                                    .quizNoneAvailable),
                              )
                            : ListView.builder(
                                //shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  int quizNumber = items[index]["number"];
                                  int trials = items[index]["num_trials"];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: Card(
                                      child: ExpansionTile(
                                        title: Text(
                                            "Quiz ${items[index]["number"].toString()}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        subtitle: Text(
                                            "${AppLocalizations.of(context)!.quizPoints}: ${items[index]["score"]} \n${AppLocalizations.of(context)!.quizAttempts}: ${items[index]["num_trials"]}"
                                            "\n${AppLocalizations.of(context)!.quizTopics}: ${items[index]["topic_names"]}"),
                                        children: [
                                          QuizDetail(
                                              startQuiz: () {
                                                setState(() {
                                                  Navigator.of(context).pop();
                                                  startTrial(quizNumber);
                                                });
                                              },
                                              returnToQuizList: () {
                                                setState(() {
                                                  futureQuizList =
                                                      fetchFunction();
                                                });
                                              },
                                              quiz: items[index])
                                        ],
                                        //minVerticalPadding: 10.0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      );
                    } else if (snapshot.connectionState !=
                        ConnectionState.done) {
                      return const Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return DynamicErrorWidget(onRefresh: () {
                        setState(() {
                          futureQuizList = fetchFunction();
                        });
                      });
                    } else {
                      return const Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
  }
}

class QuizDetail extends StatelessWidget {
  const QuizDetail(
      {Key? key,
      required this.startQuiz,
      required this.quiz,
      required this.returnToQuizList})
      : super(key: key);

  final Function() startQuiz;
  final Function() returnToQuizList;
  final Map quiz;

  @override
  Widget build(BuildContext context) {
    var trials = quiz["trials"];
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trials.length,
              itemBuilder: (context, index) {
                var trial = trials[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "${AppLocalizations.of(context)!.quizAttempt}: ${trial["number"]}"),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                              "${AppLocalizations.of(context)!.quizPoints}: ${trial["is_completed"] ? trial["score"] : "-"}"),
                          Text(
                              "${AppLocalizations.of(context)!.quizProgress}: ${trial["progress"]}/${trial["quiz_size"]}"),
                        ]),
                    const SizedBox(
                      height: 5,
                    ),
                    if (!trial["is_completed"])
                      ElevatedButton(
                        onPressed: () => showYesNoWarningDialog(
                          context: context,
                          text:
                              AppLocalizations.of(context)!.quizContinueAttempt,
                          methodOnYes: () {
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => QuizPage(
                                          quizNumber: quiz["number"],
                                          trialNumber: trial["number"],
                                        )))
                                .then((value) {
                              returnToQuizList();
                            });
                          },
                        ),
                        child: Text(AppLocalizations.of(context)!.quizContinue),
                      ),
                    const Divider(
                      thickness: 2,
                    ),
                  ],
                );
              }),
          if (quiz["num_trials"] < MAX_TRIALS)
            ElevatedButton(
              onPressed: () {
                showYesNoWarningDialog(
                  context: context,
                  text: AppLocalizations.of(context)!.quizBeginAttemptWarning,
                  methodOnYes: startQuiz,
                );
              },
              child: Text(AppLocalizations.of(context)!.quizBeginAttempt),
            )
        ],
      ),
    );
  }
}
