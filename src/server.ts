import express from 'express';

const app = express();

app.get('/', (_req, res) => res.send('Hello SP-Fashion!'));
app.get('/healthz', (_req, res) => res.json({ ok: true }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
