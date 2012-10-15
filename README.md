README
======

使い方
------

こんな感じに.vimrcに設定を書いとく

    if !exists('g:peercast')
      let g:peercast = {}
    endif
    let g:peercast.tmpdir = expand("~/.tmp")
    let g:peercast.yp_list = ['http://temp.orz.hm/yp/', 'http://bayonet.ddo.jp/sp/', 'http://wp.prgrssv.net/', 'http://oekakiyp.appspot.com/', 'http://eventyp.xrea.jp/']
    let g:peercast.host = 'localhost:7144'
    let g:peercast.player = 'E:/Applications/pcwmp/pcwmp.exe'
    let g:peercast.browser = 'D:/Program Files (x86)/Jane Style/Jane2ch.exe'

最初に:Unite peercast/updateしてください。

* :Unite peercast
  チャンネル閲覧用
* :Unite peercast/bbs
  チャンネルコンタクトURLからブラウザ表示用
* :Unite peercast/update
  キャッシュの更新用

TODO
----

* アクションを作る
* 最初、自動でupdateする
* 一定時間たったときにupdateする
* docを書く

