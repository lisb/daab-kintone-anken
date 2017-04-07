# 案件ボット for kintone

## はじめに

このドキュメントは、direct と kintone を連携させた案件ボット(以下、ボット)について、各種設定から実行するまでの手順書となっています。そのため、direct および kintone の両サービスをご契約・ご利用中のものとしています。

まだ、ご利用でない方は、[direct](https://direct4b.com/ja/) および [kintone](https://kintone.cybozu.com/jp/) のそれぞれに無料トライアルがありますので、そちらをご参照ください。

## ボット用アカウントの取得

ボット用に、新しくメールアドレスを個別に用意します。例えば、案件ボット用に用意したアドレスが `hubot-anken@example.com` だとすると、`hubot-anken@example.com` が direct のログインID、`hubot-anken`が kintone のログインIDになるように登録します。


### direct 

通常のユーザと同じように、ボット用アカウントを作成します。

組織の管理ツールから、ボット用メールアドレスに招待メールを送信します。
管理ツールのご利用方法については、[こちらの管理ツールマニュアル](https://direct4b.com/ja/manual_dl.html)をご参照ください。管理ツールのご利用には権限が必要です。お持ちでない方は、契約者もしくは管理者にご連絡下さい。

組織に招待されると、ボット用メールアドレスにメールが届きます。
メールに記載されているURLをクリックしてアカウント登録手続きをしてください。ご利用開始までの手順については、[こちらの導入マニュアル](https://direct4b.com/ja/manual_dl.html)をご参照ください。

[ログインページ](https://direct4b.com/signin)からボット用メールアドレスでログインします。
招待を承認する画面が開きますので、その画面で「承認」を選択してください。
次に、設定＞プロフィール編集より、表示名とプロフィール画像をボット用に変更します。

### kintone

通常のユーザと同じように、ボット用アカウントを作成します。

cybozu.com 共通管理からユーザを追加します。cybozu.com 共通管理のご利用方法については、[こちらのヘルプページ](https://help.cybozu.com/ja/general/admin/add_user.html)をご参照ください。共通管理のご利用には権限が必要です。お持ちでない方は、管理者にご連絡下さい。

ログインIDを入力するとき、directに登録したメールアドレスが `xxx@yyy.com` だとすると、`xxx`が kintone のログインIDになるようにします。

案件アプリをアプリストアから追加します。アプリストアからのアプリ追加方法については、[こちらのヘルプページ](https://help.cybozu.com/ja/k/user/add_app_store.html)をご参照ください。

## node のインストール

[http://nodejs.org/](http://nodejs.org/) から最新版をインストールします。v6.2.1 で動作確認しています。

## サンプルプログラムの設定

サンプルプログラムを[ダウンロード](kintone-anken-download.html)して展開します。以降は、この展開したディレクトリ(フォルダ)にて、コマンドライン(コマンドプロンプト)で作業することになります。

### direct

direct へのアクセスには、アクセストークンが利用されます。アクセストークンの取得には、アクセストークンを環境変数に設定していない状態で、以下のコマンドを実行し、ボット用のメールアドレスとパスワードを入力します。

	$ bin/hubot
	Email: loginid@bot.email.com
	Password: *****
	0123456789ABCDEF_your_direct_access_token

以下の環境変数に、アクセストークンを設定します。
	
	$ export HUBOT_DIRECT_TOKEN=0123456789ABCDEF_your_direct_access_token
	

### kintone

kintone へのアクセスには、[パスワード認証(X-Cybozu-Authorization)](https://cybozudev.zendesk.com/hc/ja/articles/201941754-REST-API%E3%81%AE%E5%85%B1%E9%80%9A%E4%BB%95%E6%A7%98#step7)が利用されます。

以下の環境変数に、取得したアカウントの「ログイン名:パスワード」をBASE64エンコードして設定します。

	$ export HUBOT_CYBOZU_ANKEN_AUTH=`echo -n 'anken_login_id:password' | base64`

以下の環境変数に、kintone REST API の[リクエストURI](https://cybozudev.zendesk.com/hc/ja/articles/201941754-REST-API%E3%81%AE%E5%85%B1%E9%80%9A%E4%BB%95%E6%A7%98#step9)を設定します。

	$ export HUBOT_CYBOZU_URI=https://(サブドメイン名).cybozu.com/k/v1

以下の環境変数に、アプリの情報を取得するアプリIDを指定します。

	$ export HUBOT_CYBOZU_ANKEN_APPID=13

## サンプルプログラムの実行

以下のコマンドを実行します。

	$ bin/hubot
