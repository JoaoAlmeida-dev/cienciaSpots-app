import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ciencia_spots/pages/home/home_page.dart';
import 'package:ciencia_spots/services/logging/LoggerService.dart';

class Result extends StatelessWidget {
  final int resultScore;
  final Function() resetHandler;

  const Result(this.resultScore, this.resetHandler, {Key? key})
      : super(key: key);

//Remark Logic
  String get resultPhrase {
    String resultText;
    if (resultScore >= 50) {
      resultText = 'Perfeito!';
      LoggerService.instance.debug(resultScore);
    }
    if (resultScore >= 41) {
      resultText = 'Muito bom!';
      LoggerService.instance.debug(resultScore);
    } else if (resultScore >= 31) {
      resultText = 'Bom desempenho!';
      LoggerService.instance.debug(resultScore);
    } else if (resultScore >= 21) {
      resultText = 'Razoável';
    } else if (resultScore >= 10) {
      resultText = 'Fraco';
      LoggerService.instance.debug(resultScore);
    } else {
      resultText = 'Zero';
      LoggerService.instance.debug(resultScore);
    }
    return resultText;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            AppLocalizations.of(context)?.quizComplete ?? "Quiz",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          /*Text(
            'Pontos: ' '$resultScore',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ), //Text*/
          ElevatedButton(
            child: Text(
              AppLocalizations.of(context)?.back ?? "Back",
            ), //Te
            onPressed: () {
              /*
              Navigator.pushReplacement(
                context,
                PageRoutes.createRoute(
                  widget: Home(),
                ),
              );*/

              Navigator.pushReplacementNamed(context, HomePage.pageRoute);
            },
          ), //FlatButton
        ], //<Widget>[]
      ), //Column
    ); //Center
  }
}
