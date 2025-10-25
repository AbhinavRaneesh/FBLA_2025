import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import bcrypt from 'bcryptjs';
import User from './models/User.js';

// Robust .env loading regardless of where the process is started from
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const envPath = path.resolve(__dirname, '../.env');
dotenv.config({ path: envPath });

const app = express();
app.use(express.json());
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));

const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI;

// Validate MONGODB_URI early with friendly errors
const maskUri = (uri) => {
  try {
    if (!uri) return '(not set)';
    const u = new URL(uri.replace('mongodb+srv://', 'http://').replace('mongodb://', 'http://'));
    const host = u.host;
    return `mongodb(+srv)://${host}/...`;
  } catch {
    return '(invalid)';
  }
};

if (!MONGODB_URI || /<.+>/.test(MONGODB_URI)) {
  console.error('[Startup] MONGODB_URI is missing or contains placeholders.');
  console.error(`[Startup] .env path: ${envPath}`);
  console.error(`[Startup] Current value summary: ${maskUri(MONGODB_URI)}`);
  console.error('[Startup] Set MONGODB_URI in server/.env to your Atlas connection string.');
  process.exit(1);
}

// DB connect
mongoose
  .connect(MONGODB_URI, { serverSelectionTimeoutMS: 8000 })
  .then(() => console.log('MongoDB connected'))
  .catch((err) => {
    console.error('Mongo connect error', err.message);
    console.error(`[Mongo] Tried URI: ${maskUri(MONGODB_URI)}`);
    process.exit(1);
  });

// Helpers
const ensureUser = async (username) => {
  let user = await User.findOne({ username });
  if (!user) {
    // Auto-provision user with default password 'password' when accessed indirectly
    const passwordHash = await bcrypt.hash('password', 10);
    user = await User.create({ username, passwordHash });
  }
  return user;
};

// Root endpoint to confirm backend is alive
app.get('/', (req, res) => {
  res.send('FBLA 2025 API is running!');
});

// Health
app.get('/health', (req, res) => {
  res.json({ ok: true, uptime: process.uptime() });
});

// AUTH
app.post('/auth/register', async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) return res.status(400).json({ ok: false, error: 'Missing fields' });
    const exists = await User.findOne({ username });
    if (exists) return res.status(409).json({ ok: false, error: 'User exists' });
    const passwordHash = await bcrypt.hash(password, 10);
    await User.create({ username, passwordHash });
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ ok: false, error: 'Server error' });
  }
});

app.post('/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password) return res.status(400).json({ ok: false, error: 'Missing fields' });
    const user = await User.findOne({ username });
    if (!user) return res.status(401).json({ ok: false, error: 'Invalid credentials' });
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ ok: false, error: 'Invalid credentials' });
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ ok: false, error: 'Server error' });
  }
});

// POINTS
app.get('/users/:username/points', async (req, res) => {
  try {
    const { username } = req.params;
    const user = await ensureUser(username);
    return res.json({ points: user.points || 0 });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.put('/users/:username/points', async (req, res) => {
  try {
    const { username } = req.params;
    const { points } = req.body;
    if (typeof points !== 'number') return res.status(400).json({ error: 'points must be number' });
    const user = await ensureUser(username);
    user.points = Math.max(0, Math.trunc(points));
    await user.save();
    return res.json({ points: user.points });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// THEME
app.get('/users/:username/theme', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    return res.json({ theme: user.currentTheme || 'space' });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.put('/users/:username/theme', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const { theme } = req.body;
    if (!theme) return res.status(400).json({ error: 'Missing theme' });
    // Allow setting any theme; app logic ensures purchase when needed
    if (!user.themesOwned.includes(theme)) user.themesOwned.push(theme);
    user.currentTheme = theme;
    await user.save();
    return res.json({ theme: user.currentTheme });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.get('/users/:username/themes', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const themes = Array.from(new Set(['space', ...user.themesOwned]));
    return res.json({ themes });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/users/:username/themes/purchase', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const { theme } = req.body;
    if (!theme) return res.status(400).json({ error: 'Missing theme' });
    if (!user.themesOwned.includes(theme)) user.themesOwned.push(theme);
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// POWERUPS
app.get('/users/:username/powerups', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const map = {};
    for (const [k, v] of user.powerups.entries()) {
      map[k] = v;
    }
    return res.json({ powerups: map });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/users/:username/powerups/purchase', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const { powerupId } = req.body;
    if (!powerupId) return res.status(400).json({ error: 'Missing powerupId' });
    const current = user.powerups.get(powerupId) || 0;
    user.powerups.set(powerupId, current + 1);
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/users/:username/powerups/use', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const { powerupId } = req.body;
    if (!powerupId) return res.status(400).json({ error: 'Missing powerupId' });
    const current = user.powerups.get(powerupId) || 0;
    if (current <= 0) return res.status(400).json({ error: 'No powerups left' });
    if (current - 1 > 0) user.powerups.set(powerupId, current - 1);
    else user.powerups.delete(powerupId);
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

// IMPORTED SETS
app.get('/users/:username/imported-sets', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const sets = user.importedSets.map((name) => ({ name }));
    return res.json({ sets });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.post('/users/:username/imported-sets', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const { setName } = req.body;
    if (!setName) return res.status(400).json({ error: 'Missing setName' });
    if (!user.importedSets.includes(setName)) user.importedSets.push(setName);
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.delete('/users/:username/imported-sets/:setName', async (req, res) => {
  try {
    const user = await ensureUser(req.params.username);
    const { setName } = req.params;
    user.importedSets = user.importedSets.filter((n) => n !== setName);
    await user.save();
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: 'Server error' });
  }
});

app.listen(PORT, () => {
  console.log(`API listening on :${PORT}`);
});
