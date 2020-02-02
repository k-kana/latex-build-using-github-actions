# GitHub Actions を用いた LaTeX ビルドおよび PDF ファイルの生成と配置

## はじめに

このリポジトリは，「LaTeX で文章を書いて PDF を出力する」という流れを良い感じにするための環境です．
指定のディレクトリ内にコミットがあってプッシュされたら，GitHub Actions が自動的に PDF ファイルを作成します．
作成された PDF ファイルはリポジトリの [Releases](https://github.com/k-kana/latex-build-using-github-actions/releases) に Assets として配置されます．
このとき，Releases は自動的に作成されます．

![Releases](https://user-images.githubusercontent.com/20158613/73607303-b4284c80-45f7-11ea-81ba-7ea6e60a3b61.png)

また，一部のコードを変更することによって何個でも PDF ファイルを生成することができます．
例えば，卒論とその要旨を PDF で出力したいという状況であっても問題ありません．

デフォルトでは，`thesis/thesis.tex` と `abst/abst.tex` がコンパイルされ，PDF ファイルが出力されます．
後述の通り，`.github/actions/latex/entrypoint.sh` を書き換えれば，コンパイル対象を変更できます．

GitHub Actions の詳細な説明については公式の発表をご覧ください．
特に，[料金体系](https://github.com/features/actions#pricing-details)については一度ご確認ください．

## 使い方

いくつかのケースを想定して作りましたが，まずは次の作業を行なってください．

1. このリポジトリを Fork する．
2. Fork したリポジトリを自分の PC 環境に Clone する．

その後，次の編集を行なってください．

`.github/workflows/main.yml` の 17 行目にある

```
uses: k-kana/latex-build-using-github-actions/.github/actions/latex@master
``` 
を，
```
uses: ユーザ名/latex-build-using-github-actions/.github/actions/latex@master
```
に変更してください．
具体的には，冒頭の `k-kana` を自分のユーザ名に変更してください．

### 注意事項

GitHub Actions で PDF ファイルを生成する都合上，多くの場合において相対パス関係の問題が発生します．
例えば，
- 独自のクラスファイルを使う場合
- 独自のパッケージを使う場合
- `\input` で `.tex` ファイルを読み込む場合
- `\figure` で画像を読み込む場合

というような場合では，**リポジトリのルートをカレントディレクトリとした相対パス**で指定する必要があります．
`abst/fig/hoge.png` という画像を読み込みたい場合は，`\figure{./abst/hoge.png}` と書く必要があります．
他にも，上で示したようなパスを書かなければならない場合は相対パスで書いてください．

### 卒論と要旨を作成する場合

このケースを想定して作っているので，最もシンプルな手順です．

1. `thesis/thesis.tex` を編集する．
   - なお，書く内容は卒業論文を想定しているので，章別に分割しています．
   - `thesis.tex` では，`\input{./thesis/pre.tex}` とすることで，`thesis/pre.tex` を読み込んでいます．
   - 1箇所に全て書く場合は，`thesis.tex` に書き込むのがおすすめです．GitHub Actions 用の修正が不要になります．
2. `abst/abst.tex` を編集する．
   - こちらは要旨を想定しているので，単一のファイル構成になっています．
   - 基本的なルールは `thesis.tex` と同様です．
3. コミットしてプッシュする．
   - デフォルトでは，`thesis/` または `abst/` ディレクトリ内で変更があった場合（コミットされてプッシュされた場合）に PDF が生成されるようになっています．
   - もし別のディレクトリを指定したい場合は，`.github/workflows/main.yml` の 6 行目を参考に変更してください．
   - [6行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/workflows/main.yml#L6)は，`thesis/` 内に何らかの変化があった上でプッシュされた場合に，GitHub Actions を実行するという意味です．
4. Releases を確認する．
   - 実際に PDF ファイルが配置されるまでには，1分30秒から2分程度かかります．
   - Actions から眺めてみるのも良いかもしれません．

### 卒論と要旨じゃなくて，卒論（または要旨）だけで良いのだという場合

極端な話，`thesis/thesis.tex` か `abst/abst.tex` のいずれかだけ編集して，一方を放っておけば良いので，基本的には上と同じで問題ありません．
しかし，Releases には問答無用で放置していた側の PDF も生成されます．
手動で削除することも可能ですが，それだと自動化の意味が薄れてしまいます．

ここでは，`abst/abst.tex` の PDF ファイルを出力せずに，`thesis/thesis.tex` の PDF ファイルだけ出力できるようにします．

PDF ファイルを出力するための命令は，`.github/actions/latex/entrypoint.sh` 内に書かれています．
`thesis.tex` の PDF ファイル出力を行なっているのは [6行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/actions/latex/entrypoint.sh#L6)・[23行目～25行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/actions/latex/entrypoint.sh#L23)，`abst.tex` の PDF ファイル出力を行なっているのは [31行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/actions/latex/entrypoint.sh#L31)・[35行目～37行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/actions/latex/entrypoint.sh#L35)です．
いずれか不要な方を削除することで対応できます．

### そもそも卒論とかじゃなくてもっと別の文章を書きたいのだという場合

この場合は，TeX ファイルの名前変更を伴うと思われます．
もしファイル名にこだわりが無い場合は，上のケースを参考にしてください．

ファイル名に指定がある場合などは，`.github/actions/latex/entrypoint.sh` や `.github/workflows/main.yml` を編集して，実行するコマンドを変更する必要があります．

- `.github/actions/latex/entrypoint.sh`
  - LaTeX コンパイル，PDF 生成，Releases 作成， Releases への PDF 配置を担っています．
  - 上述の通り，コンパイルする `.tex` ファイルを変更する場合は，[6行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/actions/latex/entrypoint.sh#L6)・[23行目～25行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/actions/latex/entrypoint.sh#L23)，[31行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/actions/latex/entrypoint.sh#L31)・[35行目～37行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/actions/latex/entrypoint.sh#L35)を変更してください．それぞれにおいて，ファイル名を変更すれば良いです．
- `.github/workflows/main.yml`
  - GitHub Actions の発火条件などが書かれています．
  - ファイル名が変更される場合，おそらくディレクトリ名も変更になると思います．そのときは[5行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/workflows/main.yml#L5)にある `paths:` の値を変更してください．
  - [6行目](https://github.com/k-kana/latex-build-using-github-actions/blob/0b5ca8f4331df2af6baa297aeaaaf30ebfc8ffd2/.github/workflows/main.yml#L6)は，`thesis/` 内に何らかの変化があった上でプッシュされた場合に，GitHub Actions を実行するという意味です．
  - 6行目・7行目を変更することで，発火条件を変更することができます．

## 何かあった場合

Issues に投げていただけると非常にありがたいです．

メールでも構いません．[GitHub のプロフィール](https://github.com/k-kana)に公開しております．
