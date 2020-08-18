var express = require('express');
var app = express();
var server = require('http').createServer(app);
var io = require('socket.io')(server);

let ON_CONNECT = 'connection';
let ON_DISCONNECT = 'disconnect';

app.get('/', (req, res) => {
        res.send("Node Server is running. Yay!!")
});

let EVENT_SEND_MESSAGE = 'send_message';
let EVENT_RECEIVE_MESSAGE = 'receive_message';

let listen_port = process.env.PORT;
server.listen(listen_port);

io.sockets.on(ON_CONNECT, function (userSocket) {
	userSocket.on(EVENT_SEND_MESSAGE, function (chat_message) {
                userSocket.broadcast.emit(EVENT_RECEIVE_MESSAGE, chat_message);
        });
});