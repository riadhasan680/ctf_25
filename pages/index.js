'use client'
import { useState } from 'react'

export default function Home() {
  const [username, setUsername] = useState('admin')
  const [password, setPassword] = useState('')
  const [msg, setMsg] = useState('')
  const [loading, setLoading] = useState(false)
  

  const handleLogin = async (e) => {
    e.preventDefault()
    setLoading(true)
    try {
      const res = await fetch('/api/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password })
      })
      const data = await res.json()
      setMsg(data.message || 'Unknown response')
    } catch (err) {
      setMsg('Network error')
    } finally {
      setLoading(false)
    }
  }

  

  return (
    <div className="min-h-screen cyber-grid flex items-center justify-center">
      <div className="w-full max-w-md p-8 rounded-xl border border-neon-green bg-black/70 shadow-[0_0_20px_rgba(57,255,20,0.4)]">
        <h1 className="text-3xl font-bold text-neon-green text-center tracking-widest">Secure Vault Login</h1>
        <p className="text-center text-sm text-gray-400 mt-2">CTF: Blind NoSQL Injection</p>

        <form onSubmit={handleLogin} className="mt-6 space-y-4">
          <input
            className="w-full px-4 py-2 bg-black border border-neon-green/50 rounded-md outline-none text-neon-blue placeholder-gray-500 focus:border-neon-green"
            placeholder="Username"
            value={username}
            onChange={e => setUsername(e.target.value)}
          />
          <input
            className="w-full px-4 py-2 bg-black border border-neon-green/50 rounded-md outline-none text-neon-blue placeholder-gray-500 focus:border-neon-green"
            type="password"
            placeholder="Password"
            value={password}
            onChange={e => setPassword(e.target.value)}
          />
          <button
            type="submit"
            disabled={loading}
            className="w-full py-2 bg-neon-green text-black font-semibold rounded-md hover:bg-white transition"
          >
            {loading ? 'Checking…' : 'Check Credentials'}
          </button>
        </form>

        

        <p className="mt-4 text-center text-sm">{msg}</p>
      </div>
    </div>
  )
}