import mongoose from 'mongoose'
import { MongoMemoryServer } from 'mongodb-memory-server'

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/ctfdb'
mongoose.set('sanitizeFilter', false)

let cached = global._mongooseCached
if (!cached) cached = global._mongooseCached = { conn: null, promise: null, seeded: false, memServer: null }

const UserSchema = new mongoose.Schema({ username: String, secret_flag: String })
let User
try { User = mongoose.model('User') } catch { User = mongoose.model('User', UserSchema) }

async function dbConnect() {
  if (cached.conn) return cached.conn
  if (!cached.promise) {
    cached.promise = mongoose.connect(MONGODB_URI)
      .catch(async () => {
        if (!cached.memServer) {
          cached.memServer = await MongoMemoryServer.create()
        }
        const uri = cached.memServer.getUri()
        return mongoose.connect(uri)
      })
  }
  cached.conn = await cached.promise
  return cached.conn
}

async function seedDB() {
  const exists = await User.findOne({ username: 'admin' })
  if (!exists) {
    await new User({ username: 'admin', secret_flag: 'CTF{N0SQL_1nj3ct10n_1s_Fun}' }).save()
  }
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method Not Allowed' })
    return
  }

  await dbConnect()
  if (!cached.seeded) { await seedDB(); cached.seeded = true }

  const { username, password } = req.body || {}
  let passQuery = password
  if (typeof password === 'string') {
    try { const parsed = JSON.parse(password); passQuery = parsed } catch {}
  }

  try {
    let filter = { username: username }
    if (passQuery && typeof passQuery === 'object' && ('$regex' in passQuery)) {
      try {
        filter.secret_flag = new RegExp(passQuery.$regex)
      } catch {
        filter.secret_flag = passQuery
      }
    } else {
      filter.secret_flag = passQuery
    }
    const user = await User.findOne(filter)
    if (user) {
      res.status(200).json({ success: true, message: 'User validates! (But where is the flag?)' })
    } else {
      res.status(401).json({ success: false, message: 'Invalid credentials' })
    }
  } catch (err) {
    res.status(500).json({ error: 'Internal Error' })
  }
}