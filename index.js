const express = require("express")
const app = express()
const path = require("path")
const http = require("http") //載入Node.js 原生模組 http
const https = require("https")
const logModule = require("./log.js")
// console.log(msg);

const server = http.createServer(app)
// ((req, res) => 
// { //使用http提供的createServer()去建立一個http Server，包含回呼函式並使用用request及response 參數
  // res.statusCode = 200;
  // res.setHeader('Content-Type', 'text/plain');
  // res.end('Welcome to my simple website!!!!!\n');
// }); //建立server 在此處理客戶端向 http server 發送過來的 req

app.use("/", express.static("public"))
app.get("/api", (req, res) => {
    res.send("/this is api~")
})
app.get("/tttt", (req, res) => {
    res.send(`
        <h2>/tttt123</h2>
    `)
})

const port = process.env.PORT || 3000;
server.listen(port, () => {
  console.log(`Server running on port ${port}`);
}); //進入此網站的監聽 port, 就是 localhost:xxxx 的 xxxx

//const server = http.createServer(app)

//server.listen(port, "0.0.0.0", () => console.log("server start:", port))
