const http = require('http');
const { exec } = require('child_process');

const PORT = 3002; // Gunakan port yang berbeda dari aplikasi utama
const GIT_BRANCH = 'main'; // Ganti dengan nama branch Anda
const PROJECT_DIR = __dirname; // Direktori proyek saat ini

http.createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/webhook') {
    console.log('Webhook received! Pulling changes from GitHub...');

    exec(`cd ${PROJECT_DIR} && git pull origin ${GIT_BRANCH}`, (error, stdout, stderr) => {
      if (error) {
        console.error(`Git Pull Error: ${error}`);
        return;
      }
      console.log(`Git Pull Output: ${stdout}`);
      if (stderr) console.error(`Git Pull Stderr: ${stderr}`);
    });

    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Webhook processed.');
  } else {
    res.writeHead(404);
    res.end();
  }
}).listen(PORT, () => {
  console.log(`Webhook listener running on http://localhost:${PORT}`);
});