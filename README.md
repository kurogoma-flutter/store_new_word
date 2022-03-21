# store_new_word
新単語をFirestoreに登録する処理（エラーダイアログ付き）
Firestoreに登録する際のバリデーションチェック＋TextFieldの学習

## 実装結果
### トップ画面
<img width="300" src="https://user-images.githubusercontent.com/67848399/159214205-fa24377b-2859-4806-b4de-93648ea4d9d8.png">

### Firestoreにある単語を登録しようとした場合
<img width="600" alt="section4" src="https://user-images.githubusercontent.com/67848399/159214343-4f06c89f-a1ea-4d03-8181-f71cf72ff9fe.png">
<img width="300" src="https://user-images.githubusercontent.com/67848399/159214347-e79982d2-b281-4e5a-a36c-5fa7d08bee92.png">

## メイン処理
### 文字の入力管理
```dart
  // 入力しているデータを管理するためのコントローラー
  final _controller = TextEditingController();
  String _text = '';
  // 文字が入力された際、TextFieldだけでは表面上の変化しかないため処理を追加する必要がある
  void _handleText(String e) {
    setState(() {
      _text = e;
    });
  }
```
### データの重複チェックをしてから登録
```dart
/// 単語があるか検索
    List<DocumentSnapshot> wordData = [];
    int id = _lastId + 1;
    var snapshot = await FirebaseFirestore.instance.collection('words').where('word', isEqualTo: _text).get();
    setState(() {
      wordData = snapshot.docs;
    });

    // 取得したクエリ結果が空（重複なし）の場合新規登録
    if (wordData.isEmpty) {
      await FirebaseFirestore.instance.collection('words').add({"word": _text, "id": id});
      setState(() {
        _text = '';
      });
      _controller.clear();
    } else {
      // エラー処理
    }
```
### エラー処置
```dart
return AlertDialog(
  title: const Text('登録エラー'),
  content: Text('その単語はすでにID${wordData[0]['id']}で使用されています。'),
  actions: <Widget>[
    ElevatedButton(
      child: const Text('OK'),
      onPressed: () {
        Navigator.of(context).pop();
        setState(() {
          _text = '';
        });
        _controller.clear();
      },
    ),
  ],
);
```
例えばこのAlertDialogを丸ごとresultという変数に追加した場合、
```dart
return Navigator.of(context).pop(0);
return Navigator.of(context).pop(1);
```
とすれば変数にデータを渡すことができる。
そうすることでOK,キャンセルの結果で条件分岐も可能
```dart
var result = await showDialog<int>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('結果発表！'),
              content: Text('正答 $clearCount/5'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('キャンセル'),
                  onPressed: () => Navigator.of(context).pop(0),
                ),
                ElevatedButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(1),
                ),
              ],
            );
          },
        );
// キャンセルを押した場合の処理
if(result == 0){
  ...
}
// OKを押した場合の処理
if(result == 1){
  ...
}
```

### 登録後のフォームクリア
データ登録等をした場合、自動でフォームデータがクリアになるわけではない。
このデータを手動でクリアするために以下を実装している。
```dart
setState(() {
  _text = '';
});
_controller.clear();
```
## 参考サイト
https://zenn.dev/mamushi/articles/a5e6c9f71e6ea4#islessthanorequalto%EF%BC%88%E3%80%9C%E4%BB%A5%E4%B8%8B%EF%BC%89
