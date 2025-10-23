import mongoose from 'mongoose';

const PowerupsSchema = new mongoose.Schema({}, { strict: false, _id: false });

const UserSchema = new mongoose.Schema(
  {
    username: { type: String, required: true, unique: true, index: true },
    passwordHash: { type: String, required: true },
    points: { type: Number, default: 0 },
    currentTheme: { type: String, default: 'space' },
    themesOwned: { type: [String], default: ['space'] },
    powerups: { type: Map, of: Number, default: {} },
    importedSets: { type: [String], default: [] }
  },
  { timestamps: true }
);

export default mongoose.model('User', UserSchema);
