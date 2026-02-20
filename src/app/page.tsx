'use client'

import { useState, useEffect, useCallback } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { Switch } from '@/components/ui/switch'
import { 
  Camera, 
  Link2, 
  Share2, 
  Copy, 
  Check, 
  RefreshCw, 
  Heart,
  Smartphone,
  Wifi,
  WifiOff,
  Loader2,
  Image as ImageIcon,
  Send,
  Settings,
  X,
  Download,
  Clock,
  Users
} from 'lucide-react'
import { toast } from '@/hooks/use-toast'

// Types
interface ConnectionState {
  connectionId: string | null
  lastPhotoUrl: string | null
  lastPhotoBase64: string | null
  lastCaption: string | null
  updatedAt: string | null
  isConnected: boolean
}

interface PhotoData {
  connection_id: string
  last_photo_url: string | null
  last_photo_base64: string | null
  last_caption: string | null
  updated_at: string | null
}

// Generate random connection code
function generateConnectionCode(length = 8): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  let result = ''
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return result
}

// Simulated backend storage (in production, this would be Cloudflare KV)
const connections = new Map<string, PhotoData>()

// Simulated API functions
const api = {
  async createConnection(): Promise<string> {
    await new Promise(resolve => setTimeout(resolve, 500))
    const connectionId = generateConnectionCode()
    connections.set(connectionId, {
      connection_id: connectionId,
      last_photo_url: null,
      last_photo_base64: null,
      last_caption: null,
      updated_at: new Date().toISOString()
    })
    return connectionId
  },

  async updatePhoto(connectionId: string, photoBase64: string, caption?: string): Promise<void> {
    await new Promise(resolve => setTimeout(resolve, 300))
    const existing = connections.get(connectionId)
    if (existing) {
      connections.set(connectionId, {
        ...existing,
        last_photo_base64: photoBase64,
        last_caption: caption || null,
        updated_at: new Date().toISOString()
      })
    }
  },

  async getLatestPhoto(connectionId: string): Promise<PhotoData | null> {
    await new Promise(resolve => setTimeout(resolve, 200))
    return connections.get(connectionId) || null
  }
}

export default function SnapBeamApp() {
  const [connection, setConnection] = useState<ConnectionState>({
    connectionId: null,
    lastPhotoUrl: null,
    lastPhotoBase64: null,
    lastCaption: null,
    updatedAt: null,
    isConnected: false
  })
  
  const [joinCode, setJoinCode] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [copied, setCopied] = useState(false)
  const [selectedImage, setSelectedImage] = useState<string | null>(null)
  const [caption, setCaption] = useState('')
  const [isDarkMode, setIsDarkMode] = useState(false)
  const [activeTab, setActiveTab] = useState('home')

  // Create new connection
  const handleCreateConnection = async () => {
    setIsLoading(true)
    try {
      const connectionId = await api.createConnection()
      setConnection({
        connectionId,
        lastPhotoUrl: null,
        lastPhotoBase64: null,
        lastCaption: null,
        updatedAt: null,
        isConnected: true
      })
      localStorage.setItem('snapbeam_connection', connectionId)
      toast({
        title: 'Connection Created!',
        description: `Your code is: ${connectionId}`,
      })
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to create connection',
        variant: 'destructive'
      })
    } finally {
      setIsLoading(false)
    }
  }

  // Join existing connection
  const handleJoinConnection = async () => {
    if (!joinCode || joinCode.length < 6) {
      toast({
        title: 'Invalid Code',
        description: 'Please enter a valid connection code',
        variant: 'destructive'
      })
      return
    }

    setIsLoading(true)
    try {
      const data = await api.getLatestPhoto(joinCode.toUpperCase())
      if (data) {
        setConnection({
          connectionId: joinCode.toUpperCase(),
          lastPhotoUrl: data.last_photo_url,
          lastPhotoBase64: data.last_photo_base64,
          lastCaption: data.last_caption,
          updatedAt: data.updated_at,
          isConnected: true
        })
        localStorage.setItem('snapbeam_connection', joinCode.toUpperCase())
        toast({
          title: 'Connected!',
          description: `You're now connected to ${joinCode.toUpperCase()}`,
        })
        setJoinCode('')
      } else {
        // Create new connection with this code
        const code = joinCode.toUpperCase()
        connections.set(code, {
          connection_id: code,
          last_photo_url: null,
          last_photo_base64: null,
          last_caption: null,
          updated_at: new Date().toISOString()
        })
        setConnection({
          connectionId: code,
          lastPhotoUrl: null,
          lastPhotoBase64: null,
          lastCaption: null,
          updatedAt: null,
          isConnected: true
        })
        localStorage.setItem('snapbeam_connection', code)
        toast({
          title: 'Connection Ready!',
          description: `Your code is: ${code}`,
        })
        setJoinCode('')
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to join connection',
        variant: 'destructive'
      })
    } finally {
      setIsLoading(false)
    }
  }

  // Handle image selection
  const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        setSelectedImage(e.target?.result as string)
      }
      reader.readAsDataURL(file)
    }
  }

  // Send photo
  const handleSendPhoto = async () => {
    if (!selectedImage || !connection.connectionId) return

    setIsLoading(true)
    try {
      await api.updatePhoto(connection.connectionId, selectedImage, caption)
      setConnection(prev => ({
        ...prev,
        lastPhotoBase64: selectedImage,
        lastCaption: caption,
        updatedAt: new Date().toISOString()
      }))
      setSelectedImage(null)
      setCaption('')
      toast({
        title: 'Photo Sent!',
        description: 'Your photo has been shared',
      })
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to send photo',
        variant: 'destructive'
      })
    } finally {
      setIsLoading(false)
    }
  }

  // Copy connection code
  const handleCopyCode = () => {
    if (connection.connectionId) {
      navigator.clipboard.writeText(connection.connectionId)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
      toast({
        title: 'Copied!',
        description: 'Connection code copied to clipboard',
      })
    }
  }

  // Disconnect
  const handleDisconnect = () => {
    setConnection({
      connectionId: null,
      lastPhotoUrl: null,
      lastPhotoBase64: null,
      lastCaption: null,
      updatedAt: null,
      isConnected: false
    })
    localStorage.removeItem('snapbeam_connection')
    toast({
      title: 'Disconnected',
      description: 'Your connection has been removed',
    })
  }

  // Load saved connection on mount
  useEffect(() => {
    const savedConnection = localStorage.getItem('snapbeam_connection')
    if (savedConnection) {
      api.getLatestPhoto(savedConnection).then(data => {
        if (data) {
          setConnection({
            connectionId: savedConnection,
            lastPhotoUrl: data.last_photo_url,
            lastPhotoBase64: data.last_photo_base64,
            lastCaption: data.last_caption,
            updatedAt: data.updated_at,
            isConnected: true
          })
        }
      })
    }
    
    // Check for dark mode preference
    const darkMode = localStorage.getItem('snapbeam_dark_mode')
    if (darkMode === 'true') {
      setIsDarkMode(true)
      document.documentElement.classList.add('dark')
    }
  }, [])

  // Toggle dark mode
  useEffect(() => {
    if (isDarkMode) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
    localStorage.setItem('snapbeam_dark_mode', isDarkMode.toString())
  }, [isDarkMode])

  return (
    <div className={`min-h-screen bg-gradient-to-br from-indigo-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 transition-colors duration-300`}>
      {/* Header */}
      <header className="sticky top-0 z-50 backdrop-blur-xl bg-white/80 dark:bg-gray-900/80 border-b border-gray-200 dark:border-gray-700">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 to-pink-500 flex items-center justify-center shadow-lg shadow-indigo-500/25">
              <Camera className="w-5 h-5 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold bg-gradient-to-r from-indigo-600 to-pink-600 bg-clip-text text-transparent">
                SnapBeam
              </h1>
              <p className="text-xs text-gray-500 dark:text-gray-400">
                Send moments. Instantly.
              </p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            {connection.isConnected && (
              <Badge variant="secondary" className="bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300">
                <Wifi className="w-3 h-3 mr-1" />
                Connected
              </Badge>
            )}
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setActiveTab(activeTab === 'settings' ? 'home' : 'settings')}
            >
              <Settings className="w-5 h-5" />
            </Button>
          </div>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-4 py-8">
        {activeTab === 'settings' ? (
          <SettingsPanel 
            isDarkMode={isDarkMode} 
            setIsDarkMode={setIsDarkMode}
            onDisconnect={handleDisconnect}
            isConnected={connection.isConnected}
          />
        ) : !connection.isConnected ? (
          <WelcomeScreen
            onCreateConnection={handleCreateConnection}
            onJoinConnection={handleJoinConnection}
            joinCode={joinCode}
            setJoinCode={setJoinCode}
            isLoading={isLoading}
          />
        ) : (
          <ConnectedView
            connection={connection}
            selectedImage={selectedImage}
            setSelectedImage={setSelectedImage}
            caption={caption}
            setCaption={setCaption}
            isLoading={isLoading}
            onCopyCode={handleCopyCode}
            copied={copied}
            onSendPhoto={handleSendPhoto}
            onImageSelect={handleImageSelect}
          />
        )}
      </main>

      {/* Footer */}
      <footer className="fixed bottom-0 left-0 right-0 bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl border-t border-gray-200 dark:border-gray-700 py-4">
        <div className="max-w-4xl mx-auto px-4 flex justify-center gap-8">
          <Button
            variant={activeTab === 'home' ? 'default' : 'ghost'}
            className="flex-col h-auto py-2 px-4"
            onClick={() => setActiveTab('home')}
          >
            <Camera className="w-5 h-5" />
            <span className="text-xs mt-1">Camera</span>
          </Button>
          <Button
            variant={activeTab === 'photos' ? 'default' : 'ghost'}
            className="flex-col h-auto py-2 px-4"
            onClick={() => setActiveTab('photos')}
          >
            <ImageIcon className="w-5 h-5" />
            <span className="text-xs mt-1">Photos</span>
          </Button>
          <Button
            variant={activeTab === 'settings' ? 'default' : 'ghost'}
            className="flex-col h-auto py-2 px-4"
            onClick={() => setActiveTab('settings')}
          >
            <Settings className="w-5 h-5" />
            <span className="text-xs mt-1">Settings</span>
          </Button>
        </div>
      </footer>
    </div>
  )
}

// Welcome Screen Component
function WelcomeScreen({
  onCreateConnection,
  onJoinConnection,
  joinCode,
  setJoinCode,
  isLoading
}: {
  onCreateConnection: () => void
  onJoinConnection: () => void
  joinCode: string
  setJoinCode: (code: string) => void
  isLoading: boolean
}) {
  return (
    <div className="flex flex-col items-center justify-center min-h-[70vh] animate-fade-in">
      {/* Hero */}
      <div className="text-center mb-12">
        <div className="w-24 h-24 mx-auto mb-6 rounded-3xl bg-gradient-to-br from-indigo-500 to-pink-500 flex items-center justify-center shadow-2xl shadow-indigo-500/30 animate-pulse">
          <Heart className="w-12 h-12 text-white" />
        </div>
        <h2 className="text-3xl font-bold mb-3 bg-gradient-to-r from-indigo-600 to-pink-600 bg-clip-text text-transparent">
          Welcome to SnapBeam
        </h2>
        <p className="text-gray-600 dark:text-gray-400 max-w-md mx-auto">
          Send moments. Instantly live on your loved one's home screen. No accounts, no login, just private connection codes.
        </p>
      </div>

      {/* Action Cards */}
      <div className="w-full max-w-md space-y-4">
        <Card className="border-2 border-indigo-200 dark:border-indigo-800 hover:border-indigo-400 transition-colors cursor-pointer" onClick={onCreateConnection}>
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl bg-indigo-100 dark:bg-indigo-900 flex items-center justify-center">
                <Link2 className="w-6 h-6 text-indigo-600 dark:text-indigo-400" />
              </div>
              <div className="flex-1">
                <h3 className="font-semibold text-lg">Create Connection</h3>
                <p className="text-sm text-gray-500 dark:text-gray-400">
                  Generate a new code to share with your loved ones
                </p>
              </div>
              {isLoading ? (
                <Loader2 className="w-5 h-5 animate-spin text-indigo-600" />
              ) : (
                <Check className="w-5 h-5 text-indigo-600" />
              )}
            </div>
          </CardContent>
        </Card>

        <div className="relative">
          <div className="absolute inset-0 flex items-center">
            <Separator />
          </div>
          <div className="relative flex justify-center text-xs uppercase">
            <span className="bg-white dark:bg-gray-900 px-2 text-gray-500">or</span>
          </div>
        </div>

        <Card className="border-2 border-pink-200 dark:border-pink-800">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg flex items-center gap-2">
              <Users className="w-5 h-5 text-pink-600" />
              Join Connection
            </CardTitle>
            <CardDescription>
              Enter a code shared with you
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex gap-2">
              <Input
                placeholder="Enter code (e.g., ABCD1234)"
                value={joinCode}
                onChange={(e) => setJoinCode(e.target.value.toUpperCase())}
                className="text-center text-lg tracking-widest font-mono"
                maxLength={8}
              />
              <Button 
                onClick={onJoinConnection}
                disabled={isLoading || joinCode.length < 6}
                className="bg-pink-500 hover:bg-pink-600"
              >
                {isLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Join'}
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Features */}
      <div className="grid grid-cols-3 gap-6 mt-12 max-w-2xl">
        {[
          { icon: Camera, title: 'Instant Photos', desc: 'Capture & send in seconds' },
          { icon: Smartphone, title: 'Home Screen', desc: 'Photos appear on widgets' },
          { icon: Wifi, title: 'No Accounts', desc: 'Just connection codes' }
        ].map((feature, i) => (
          <div key={i} className="text-center">
            <div className="w-12 h-12 mx-auto mb-3 rounded-xl bg-gray-100 dark:bg-gray-800 flex items-center justify-center">
              <feature.icon className="w-5 h-5 text-gray-600 dark:text-gray-400" />
            </div>
            <h4 className="font-medium text-sm">{feature.title}</h4>
            <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">{feature.desc}</p>
          </div>
        ))}
      </div>
    </div>
  )
}

// Connected View Component
function ConnectedView({
  connection,
  selectedImage,
  setSelectedImage,
  caption,
  setCaption,
  isLoading,
  onCopyCode,
  copied,
  onSendPhoto,
  onImageSelect
}: {
  connection: ConnectionState
  selectedImage: string | null
  setSelectedImage: (img: string | null) => void
  caption: string
  setCaption: (caption: string) => void
  isLoading: boolean
  onCopyCode: () => void
  copied: boolean
  onSendPhoto: () => void
  onImageSelect: (e: React.ChangeEvent<HTMLInputElement>) => void
}) {
  return (
    <div className="space-y-6 pb-24">
      {/* Connection Code Card */}
      <Card className="bg-gradient-to-r from-indigo-500 to-pink-500 text-white border-0">
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm opacity-80 mb-1">Your Connection Code</p>
              <div className="flex items-center gap-2">
                <span className="text-3xl font-mono font-bold tracking-wider">
                  {connection.connectionId}
                </span>
              </div>
            </div>
            <div className="flex gap-2">
              <Button variant="secondary" size="icon" onClick={onCopyCode}>
                {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
              </Button>
              <Button variant="secondary" size="icon">
                <Share2 className="w-4 h-4" />
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Photo Upload Section */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Camera className="w-5 h-5" />
            Send a Photo
          </CardTitle>
          <CardDescription>
            Take or select a photo to share instantly
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Image Preview */}
          <div 
            className="relative aspect-square rounded-2xl border-2 border-dashed border-gray-300 dark:border-gray-700 overflow-hidden cursor-pointer hover:border-indigo-400 transition-colors"
            onClick={() => document.getElementById('photo-input')?.click()}
          >
            {selectedImage ? (
              <img 
                src={selectedImage} 
                alt="Selected" 
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="absolute inset-0 flex flex-col items-center justify-center text-gray-400">
                <Camera className="w-12 h-12 mb-2" />
                <p className="text-sm">Tap to add a photo</p>
              </div>
            )}
            {selectedImage && (
              <Button
                variant="destructive"
                size="icon"
                className="absolute top-2 right-2 w-8 h-8"
                onClick={(e) => {
                  e.stopPropagation()
                  setSelectedImage(null)
                }}
              >
                <X className="w-4 h-4" />
              </Button>
            )}
          </div>
          
          <input
            id="photo-input"
            type="file"
            accept="image/*"
            capture="environment"
            className="hidden"
            onChange={onImageSelect}
          />

          {/* Caption */}
          <Input
            placeholder="Add a caption..."
            value={caption}
            onChange={(e) => setCaption(e.target.value)}
            className="w-full"
          />

          {/* Send Button */}
          <Button 
            className="w-full bg-gradient-to-r from-indigo-500 to-pink-500 hover:from-indigo-600 hover:to-pink-600"
            disabled={!selectedImage || isLoading}
            onClick={onSendPhoto}
          >
            {isLoading ? (
              <>
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                Sending...
              </>
            ) : (
              <>
                <Send className="w-4 h-4 mr-2" />
                Send Photo
              </>
            )}
          </Button>
        </CardContent>
      </Card>

      {/* Last Photo Received */}
      {connection.lastPhotoBase64 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <ImageIcon className="w-5 h-5" />
              Latest Photo
            </CardTitle>
            {connection.updatedAt && (
              <CardDescription className="flex items-center gap-1">
                <Clock className="w-3 h-3" />
                {new Date(connection.updatedAt).toLocaleString()}
              </CardDescription>
            )}
          </CardHeader>
          <CardContent>
            <div className="relative rounded-xl overflow-hidden">
              <img 
                src={connection.lastPhotoBase64} 
                alt="Last shared" 
                className="w-full aspect-square object-cover"
              />
              {connection.lastCaption && (
                <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-4">
                  <p className="text-white text-sm">{connection.lastCaption}</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

// Settings Panel Component
function SettingsPanel({
  isDarkMode,
  setIsDarkMode,
  onDisconnect,
  isConnected
}: {
  isDarkMode: boolean
  setIsDarkMode: (mode: boolean) => void
  onDisconnect: () => void
  isConnected: boolean
}) {
  return (
    <div className="space-y-6 pb-24">
      <h2 className="text-2xl font-bold">Settings</h2>

      {/* Appearance */}
      <Card>
        <CardHeader>
          <CardTitle>Appearance</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-gray-100 dark:bg-gray-800 flex items-center justify-center">
                {isDarkMode ? (
                  <div className="w-5 h-5 rounded-full bg-gray-900" />
                ) : (
                  <div className="w-5 h-5 rounded-full bg-yellow-400" />
                )}
              </div>
              <div>
                <p className="font-medium">Dark Mode</p>
                <p className="text-sm text-gray-500">Switch between light and dark themes</p>
              </div>
            </div>
            <Switch checked={isDarkMode} onCheckedChange={setIsDarkMode} />
          </div>
        </CardContent>
      </Card>

      {/* Widget Setup */}
      <Card>
        <CardHeader>
          <CardTitle>Widget Setup</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className="text-sm text-gray-600 dark:text-gray-400">
            Add the SnapBeam widget to your home screen to see photos from your loved ones instantly.
          </p>
          <div className="space-y-2 text-sm">
            <div className="flex items-start gap-2">
              <Badge variant="outline">Android</Badge>
              <p className="text-gray-600 dark:text-gray-400">
                Long press home screen → Widgets → SnapBeam
              </p>
            </div>
            <div className="flex items-start gap-2">
              <Badge variant="outline">iOS</Badge>
              <p className="text-gray-600 dark:text-gray-400">
                Long press home screen → + → SnapBeam
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Connection */}
      <Card>
        <CardHeader>
          <CardTitle>Connection</CardTitle>
        </CardHeader>
        <CardContent>
          <Button 
            variant="destructive" 
            className="w-full"
            disabled={!isConnected}
            onClick={onDisconnect}
          >
            <WifiOff className="w-4 h-4 mr-2" />
            Disconnect
          </Button>
        </CardContent>
      </Card>

      {/* About */}
      <Card>
        <CardHeader>
          <CardTitle>About SnapBeam</CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <p className="text-sm text-gray-600 dark:text-gray-400">
            SnapBeam lets you share moments instantly with your loved ones. 
            No accounts, no login - just simple connection codes.
          </p>
          <p className="text-sm text-gray-500">Version 1.0.0</p>
        </CardContent>
      </Card>
    </div>
  )
}
