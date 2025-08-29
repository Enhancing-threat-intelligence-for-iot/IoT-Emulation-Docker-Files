const WebSocket = require("ws");
const http = require("http");

// Create HTTP server
const server = http.createServer();

// Create WebSocket server
const wss = new WebSocket.Server({
  server: server,
  port: 8080,
});

console.log("WebSocket server starting on port 8080...");

wss.on("connection", function connection(ws, req) {
  console.log(`New WebSocket connection from ${req.socket.remoteAddress}`);

  // Send welcome message
  ws.send(
    JSON.stringify({
      type: "welcome",
      message: "Connected to PolyMTL WebSocket server",
      timestamp: new Date().toISOString(),
    })
  );

  // Handle incoming messages
  ws.on("message", function incoming(data) {
    console.log("Received:", data.toString());

    try {
      const message = JSON.parse(data.toString());

      // Echo the message back
      ws.send(
        JSON.stringify({
          type: "echo",
          original: message,
          timestamp: new Date().toISOString(),
        })
      );
    } catch (error) {
      // Send error response for invalid JSON
      ws.send(
        JSON.stringify({
          type: "error",
          message: "Invalid JSON format",
          timestamp: new Date().toISOString(),
        })
      );
    }
  });

  // Handle connection close
  ws.on("close", function close() {
    console.log("WebSocket connection closed");
  });

  // Handle errors
  ws.on("error", function error(err) {
    console.error("WebSocket error:", err);
  });

  // Send periodic ping messages
  const pingInterval = setInterval(() => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(
        JSON.stringify({
          type: "ping",
          timestamp: new Date().toISOString(),
        })
      );
    } else {
      clearInterval(pingInterval);
    }
  }, 30000); // Send ping every 30 seconds
});

wss.on("error", function error(err) {
  console.error("WebSocket server error:", err);
});

// Start the server
server.listen(8080, () => {
  console.log("WebSocket server listening on port 8080");
});

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("Shutting down WebSocket server...");
  wss.close(() => {
    server.close(() => {
      process.exit(0);
    });
  });
});
