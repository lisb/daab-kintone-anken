# Description:
#   kintoneの案件管理アプリのデータを参照します。
# 
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_CYBOZU_URI
#   HUBOT_CYBOZU_ANKEN_AUTH
#   HUBOT_CYBOZU_ANKEN_APPID
#
# Commands:
#   hubot 案件 - 最新5件の案件を表示します。
#   hubot <会社名>の件 - <会社名>の案件を表示します。(最新5件)
#   hubot <担当者名>さんの担当 - 先方担当者が<担当者名>の案件を表示します。(最新5件)
#   hubot 売上 - 今月と先月の売り上げを表示します。
#
# Author:
#   masataka.takeuchi

endpoint = process.env.HUBOT_CYBOZU_URI
auth     = process.env.HUBOT_CYBOZU_ANKEN_AUTH
appId    = process.env.HUBOT_CYBOZU_ANKEN_APPID

if endpoint? then endpoint = endpoint.replace(/\/$/, "")

ankenField  = "文字列__1行_"
assignField = "文字列__1行__1"

module.exports = (robot) ->
  robot.hear /案件/i, (msg) ->
    findAnken msg, "", (text) ->
      msg.send text

  robot.hear /([^。、.,]{2,})(の案?件).*/i, (msg) ->
    findAnken msg, "#{ankenField} like \"" + msg.match[1] + "\"", (text) ->
      msg.send text

  robot.hear /([^。、.,]{2,5})(さん|くん|君).*/i, (msg) ->
    findAnken msg, "#{assignField} like \"" + msg.match[1] + "\"", (text) ->
      msg.send text

  robot.hear /売り?上げ?/i, (msg) ->
    calcAnken msg, "(日付 >= LAST_MONTH()) and (日付 < THIS_MONTH())", 0, (lastMonth) ->
      calcAnken msg, "日付 >= THIS_MONTH()", 0, (thisMonth) ->
        msg.send "売り上げ\n先月: " + lastMonth + "円\n今月: " + thisMonth + "円"

findAnken = (msg, query, cb) ->
  msg.http(endpoint + '/records.json')
    .header("X-Cybozu-Authorization", auth)
    .query(
      app: appId
      query: query + " order by 日付 desc limit 5"
      )
    .get() (err, res, body) ->
      result = JSON.parse body
      if result?
        if result.records? && result.records.length > 0
          cb (formatAnken record for record in result.records).join("\n")
        #else
        #  cb "すみません、'#{query}'の検索結果はありませんでした"

calcAnken = (msg, query, total, cb) ->
  msg.http(endpoint + '/records.json')
    .header("X-Cybozu-Authorization", auth)
    .query(
      app: appId
      query: query + " limit 100"
      "fields[0]": "計算"
      )
    .get() (err, res, body) ->
      result = JSON.parse body
      if result? && result.records?
        total += parseInt(record.計算.value) for record in result.records
        if result.records.length == 100
          calcAnken msg, query, total, cb
        else
          cb total

formatAnken = (record) ->
  [ record[ankenField].value + " (担当: " + record[assignField].value + ")",
    " 見込み時期: " + record.日付.value,
    " 確度: "      + record.ラジオボタン.value,
    " 製品名: "    + record.ドロップダウン.value + " (単価: " + record.単価.value + "円)",
    " 小計: "      + record.計算.value + "円 (ユーザー数: " + record.ユーザー数.value + "人)",
    "#{endpoint.replace('/v1', '/'+appId)}/show#record=" + record.レコード番号.value
    ""
  ].join("\n")
    
  
