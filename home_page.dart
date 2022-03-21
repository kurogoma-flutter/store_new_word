import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// 　問題３で作ったアプリケーションを改良する。テキストボックスに単語を入力すると、
// その単語がすでにデータベースに存在しているならIDを表示し、
// 存在していなければデータベースに新たなIDとともに追加される機能を追加せよ。

class Section4 extends StatefulWidget {
  const Section4({Key? key}) : super(key: key);

  @override
  _Section4State createState() => _Section4State();
}

class _Section4State extends State<Section4> {
  // 入力しているデータを管理するためのコントローラー
  final _controller = TextEditingController();
  String _text = '';
  // 文字が入力された際、TextFieldだけでは表面上の変化しかないため処理を追加
  void _handleText(String e) {
    setState(() {
      _text = e;
    });
  }

  _storeNewWord() async {
    if (_text == '') {
      return print('データを入力してください');
    }

    /// IDの一番大きい値を取得したい
    List<DocumentSnapshot> wordList = [];
    int _lastId;
    var snapshotId = await FirebaseFirestore.instance.collection('words').orderBy('id', descending: true).limit(1).get();
    setState(() {
      wordList = snapshotId.docs;
    });
    _lastId = wordList[0]['id'];

    /// 単語があるか検索
    List<DocumentSnapshot> wordData = [];
    int id = _lastId + 1;
    var snapshot = await FirebaseFirestore.instance.collection('words').where('word', isEqualTo: _text).get();
    setState(() {
      wordData = snapshot.docs;
    });

    if (wordData.isEmpty) {
      print(_text);
      print(id);
      await FirebaseFirestore.instance.collection('words').add({"word": _text, "id": id});
      setState(() {
        _text = '';
      });
      _controller.clear();
    } else {
      print(_text);

      /// モーダルを出す
      return await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('登録エラー'),
            content: Text('その単語はすでにID${wordData[0]['id']}で使用されています。'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(1);
                  setState(() {
                    _text = '';
                  });
                  _controller.clear();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Section4'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: <Widget>[
                Text(
                  _text,
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 30.0, fontWeight: FontWeight.w500),
                ),
                TextField(
                  controller: _controller,
                  enabled: true,
                  // 入力数
                  maxLength: 30,
                  style: const TextStyle(color: Colors.red),
                  obscureText: false,
                  maxLines: 1,
                  onChanged: _handleText,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () => _storeNewWord(),
              child: const Text('単語登録'),
            ),
          ),
        ],
      ),
    );
  }
}
