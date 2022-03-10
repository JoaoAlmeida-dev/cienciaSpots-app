import 'package:flutter/material.dart';
import 'package:iscte_spots/widgets/nav_drawer/page_routes.dart';
import 'package:logger/logger.dart';

class Result extends StatelessWidget {
  final Logger _logger = Logger();
  final int resultScore;
  final Function() resetHandler;

  Result(this.resultScore, this.resetHandler, {Key? key}) : super(key: key);

//Remark Logic
  String get resultPhrase {
    String resultText;
    if (resultScore >= 50) {
      resultText = 'Perfeito!';
      _logger.d(resultScore);
    }
    if (resultScore >= 41) {
      resultText = 'Muito bom!';
      _logger.d(resultScore);
    } else if (resultScore >= 31) {
      resultText = 'Bom desempenho!';
      _logger.d(resultScore);
    } else if (resultScore >= 21) {
      resultText = 'Razoável';
    } else if (resultScore >= 10) {
      resultText = 'Fraco';
      _logger.d(resultScore);
    } else {
      resultText = 'Zero';
      _logger.d(resultScore);
    }
    return resultText;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Quiz 1 concluído",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ), //Text
          /*Text(
            'Pontos: ' '$resultScore',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ), //Text*/
          ElevatedButton(
            child: const Text(
              'Voltar ao menu',
            ), //Te
            onPressed: () {
              Navigator.pushReplacementNamed(context, PageRoutes.home);
            },
          ), //FlatButton
        ], //<Widget>[]
      ), //Column
    ); //Center
  }
}
