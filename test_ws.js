const WebSocket = require('ws');
const ws = new WebSocket('ws://127.0.0.1:9092');
ws.on('open', () => {
  console.log('connected');
  ws.send('hello');
});
ws.on('message', (data) => {
  console.log('received:', data.toString());
  ws.close();
});
