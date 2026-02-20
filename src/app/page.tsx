'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { Switch } from '@/components/ui/switch'
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { 
  Camera, Link2, Share2, Copy, Check, Heart, Smartphone, Wifi, WifiOff,
  Loader2, Image as ImageIcon, Send, Settings, X, Clock, Users, Widget,
  ArrowRight, Sparkles, Diamond, Lock
} from 'lucide-react'
import { toast } from '@/hooks/use-toast'

// Types
interface ConnectionState {
  connectionId: string | null
  lastPhotoBase64: string | null
  lastCaption: string | null
  updatedAt: string | null
  isConnected: boolean
}

interface PhotoData {
  connection_id: string
  last_photo_base64: string | null
  last_caption: string | null
  updated_at: string | null
}

// Usage tracking
interface UsageData {
  sendsToday: number
  lastResetDate: string
  isPremium: boolean
}

const FREE_DAILY_LIMIT = 2

function getUsage(): UsageData {
  if (typeof window === 'undefined') return { sendsToday: 0, lastResetDate: '', isPremium: false }
  
  const stored = localStorage.getItem('snapbeam_usage')
  if (!stored) return { sendsToday: 0, lastResetDate: getTodayString(), isPremium: false }
  
  const usage = JSON.parse(stored) as UsageData
  if (usage.lastResetDate !== getTodayString()) {
    return { sendsToday: 0, lastResetDate: getTodayString(), isPremium: usage.isPremium }
  }
  return usage
}

function saveUsage(usage: UsageData) {
  localStorage.setItem('snapbeam_usage', JSON.stringify(usage))
}

function getTodayString(): string {
  const now = new Date()
  return `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`
}

function getTimeUntilReset(): string {
  const now = new Date()
  const tomorrow = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1)
  const diff = tomorrow.getTime() - now.getTime()
  const hours = Math.floor(diff / (1000 * 60 * 60))
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
  return `${hours}h ${minutes}m`
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

// Simulated backend storage
const connections = new Map<string, PhotoData>()

// Simulated API functions
const api = {
  async createConnection(): Promise<string> {
    await new Promise(resolve => setTimeout(resolve, 500))
    const connectionId = generateConnectionCode()
    connections.set(connectionId, {
      connection_id: connectionId,
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

// App stages
type AppStage = 'splash' | 'widget-setup' | 'main' | 'premium'

export default function SnapBeamApp() {
  const [stage, setStage] = useState<AppStage>('splash')
  const [connection, setConnection] = useState<ConnectionState>({
    connectionId: null,
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
  const [usage, setUsage] = useState<UsageData>({ sendsToday: 0, lastResetDate: '', isPremium: false })
  const [showLimitDialog, setShowLimitDialog] = useState(false)

  const remainingSends = usage.isPremium ? -1 : FREE_DAILY_LIMIT - usage.sendsToday

  // Splash screen timer
  useEffect(() => {
    const timer = setTimeout(() => {
      const hasSeenWidgetSetup = localStorage.getItem('snapbeam_widget_setup_seen')
      if (hasSeenWidgetSetup === 'true') {
        setStage('main')
      } else {
        setStage('widget-setup')
      }
    }, 2500)
    return () => clearTimeout(timer)
  }, [])

  // Load usage and connection on mount
  useEffect(() => {
    setUsage(getUsage())
    
    const savedConnection = localStorage.getItem('snapbeam_connection')
    if (savedConnection) {
      api.getLatestPhoto(savedConnection).then(data => {
        if (data) {
          setConnection({
            connectionId: savedConnection,
            lastPhotoBase64: data.last_photo_base64,
            lastCaption: data.last_caption,
            updatedAt: data.updated_at,
            isConnected: true
          })
        }
      })
    }
    
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

  // Create new connection
  const handleCreateConnection = async () => {
    setIsLoading(true)
    try {
      const connectionId = await api.createConnection()
      setConnection({
        connectionId,
        lastPhotoBase64: null,
        lastCaption: null,
        updatedAt: null,
        isConnected: true
      })
      localStorage.setItem('snapbeam_connection', connectionId)
      toast({ title: 'Connection Created!', description: `Your code is: ${connectionId}` })
    } catch (error) {
      toast({ title: 'Error', description: 'Failed to create connection', variant: 'destructive' })
    } finally {
      setIsLoading(false)
    }
  }

  // Join existing connection
  const handleJoinConnection = async () => {
    if (!joinCode || joinCode.length < 6) {
      toast({ title: 'Invalid Code', description: 'Please enter a valid connection code', variant: 'destructive' })
      return
    }

    setIsLoading(true)
    try {
      const data = await api.getLatestPhoto(joinCode.toUpperCase())
      if (data) {
        setConnection({
          connectionId: joinCode.toUpperCase(),
          lastPhotoBase64: data.last_photo_base64,
          lastCaption: data.last_caption,
          updatedAt: data.updated_at,
          isConnected: true
        })
        localStorage.setItem('snapbeam_connection', joinCode.toUpperCase())
        toast({ title: 'Connected!', description: `You're now connected to ${joinCode.toUpperCase()}` })
        setJoinCode('')
      } else {
        const code = joinCode.toUpperCase()
        connections.set(code, {
          connection_id: code,
          last_photo_base64: null,
          last_caption: null,
          updated_at: new Date().toISOString()
        })
        setConnection({
          connectionId: code,
          lastPhotoBase64: null,
          lastCaption: null,
          updatedAt: null,
          isConnected: true
        })
        localStorage.setItem('snapbeam_connection', code)
        toast({ title: 'Connection Ready!', description: `Your code is: ${code}` })
        setJoinCode('')
      }
    } catch (error) {
      toast({ title: 'Error', description: 'Failed to join connection', variant: 'destructive' })
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

    // Check limit
    if (!usage.isPremium && usage.sendsToday >= FREE_DAILY_LIMIT) {
      setShowLimitDialog(true)
      return
    }

    setIsLoading(true)
    try {
      await api.updatePhoto(connection.connectionId, selectedImage, caption)
      
      // Update usage
      const newUsage = { ...usage, sendsToday: usage.sendsToday + 1 }
      saveUsage(newUsage)
      setUsage(newUsage)
      
      setConnection(prev => ({
        ...prev,
        lastPhotoBase64: selectedImage,
        lastCaption: caption,
        updatedAt: new Date().toISOString()
      }))
      setSelectedImage(null)
      setCaption('')
      toast({ title: 'Photo Sent!', description: 'Your photo has been shared' })
    } catch (error) {
      toast({ title: 'Error', description: 'Failed to send photo', variant: 'destructive' })
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
      toast({ title: 'Copied!', description: 'Connection code copied to clipboard' })
    }
  }

  // Disconnect
  const handleDisconnect = () => {
    setConnection({
      connectionId: null,
      lastPhotoBase64: null,
      lastCaption: null,
      updatedAt: null,
      isConnected: false
    })
    localStorage.removeItem('snapbeam_connection')
    toast({ title: 'Disconnected', description: 'Your connection has been removed' })
  }

  // Complete widget setup
  const handleWidgetSetupComplete = () => {
    localStorage.setItem('snapbeam_widget_setup_seen', 'true')
    setStage('main')
  }

  // Render based on stage
  if (stage === 'splash') {
    return <SplashScreen />
  }

  if (stage === 'widget-setup') {
    return <WidgetSetupScreen onComplete={handleWidgetSetupComplete} onSkip={handleWidgetSetupComplete} />
  }

  if (stage === 'premium') {
    return <PremiumScreen onBack={() => setStage('main')} />
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 transition-colors duration-300">
      {/* Header */}
      <header className="sticky top-0 z-50 backdrop-blur-xl bg-white/80 dark:bg-gray-900/80 border-b border-gray-200 dark:border-gray-700">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 to-pink-500 flex items-center justify-center shadow-lg shadow-indigo-500/25">
              <Camera className="w-5 h-5 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold bg-gradient-to-r from-indigo-600 to-pink-600 bg-clip-text text-transparent">SnapBeam</h1>
              <p className="text-xs text-gray-500 dark:text-gray-400">Send moments. Instantly.</p>
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            {connection.isConnected && (
              <Badge variant="secondary" className="bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300">
                <Wifi className="w-3 h-3 mr-1" /> Connected
              </Badge>
            )}
            <Button variant="ghost" size="icon" onClick={() => setStage('premium')}>
              <Diamond className="w-5 h-5 text-amber-500" />
            </Button>
            <Button variant="ghost" size="icon" onClick={() => setActiveTab(activeTab === 'settings' ? 'home' : 'settings')}>
              <Settings className="w-5 h-5" />
            </Button>
          </div>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-4 py-8">
        {activeTab === 'settings' ? (
          <SettingsPanel isDarkMode={isDarkMode} setIsDarkMode={setIsDarkMode} onDisconnect={handleDisconnect}
            isConnected={connection.isConnected} onShowWidgetSetup={() => setStage('widget-setup')}
            onShowPremium={() => setStage('premium')} />
        ) : !connection.isConnected ? (
          <WelcomeScreen onCreateConnection={handleCreateConnection} onJoinConnection={handleJoinConnection}
            joinCode={joinCode} setJoinCode={setJoinCode} isLoading={isLoading} />
        ) : (
          <ConnectedView connection={connection} selectedImage={selectedImage} setSelectedImage={setSelectedImage}
            caption={caption} setCaption={setCaption} isLoading={isLoading} onCopyCode={handleCopyCode} copied={copied}
            onSendPhoto={handleSendPhoto} onImageSelect={handleImageSelect} remainingSends={remainingSends}
            usage={usage} onShowPremium={() => setStage('premium')} />
        )}
      </main>

      {/* Footer */}
      <footer className="fixed bottom-0 left-0 right-0 bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl border-t border-gray-200 dark:border-gray-700 py-4">
        <div className="max-w-4xl mx-auto px-4 flex justify-center gap-8">
          <Button variant={activeTab === 'home' ? 'default' : 'ghost'} className="flex-col h-auto py-2 px-4" onClick={() => setActiveTab('home')}>
            <Camera className="w-5 h-5" /><span className="text-xs mt-1">Camera</span>
          </Button>
          <Button variant={activeTab === 'photos' ? 'default' : 'ghost'} className="flex-col h-auto py-2 px-4" onClick={() => setActiveTab('photos')}>
            <ImageIcon className="w-5 h-5" /><span className="text-xs mt-1">Photos</span>
          </Button>
          <Button variant={activeTab === 'settings' ? 'default' : 'ghost'} className="flex-col h-auto py-2 px-4" onClick={() => setActiveTab('settings')}>
            <Settings className="w-5 h-5" /><span className="text-xs mt-1">Settings</span>
          </Button>
        </div>
      </footer>

      {/* Limit Reached Dialog */}
      <Dialog open={showLimitDialog} onOpenChange={setShowLimitDialog}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Lock className="w-5 h-5 text-red-500" /> Daily Limit Reached
            </DialogTitle>
            <DialogDescription>
              You've used your {FREE_DAILY_LIMIT} free photo sends for today. Upgrade to Premium for unlimited sends!
            </DialogDescription>
          </DialogHeader>
          <div className="p-4 bg-muted rounded-lg">
            <p className="text-sm text-muted-foreground text-center">
              Resets in: <span className="font-bold text-foreground">{getTimeUntilReset()}</span>
            </p>
          </div>
          <DialogFooter className="flex gap-2">
            <Button variant="outline" onClick={() => setShowLimitDialog(false)}>Maybe Later</Button>
            <Button onClick={() => { setShowLimitDialog(false); setStage('premium') }} className="bg-gradient-to-r from-amber-500 to-orange-500">
              <Diamond className="w-4 h-4 mr-2" /> Go Premium
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}

// ============================================
// SPLASH SCREEN
// ============================================
function SplashScreen() {
  const [showTagline, setShowTagline] = useState(false)
  useEffect(() => {
    const timer = setTimeout(() => setShowTagline(true), 800)
    return () => clearTimeout(timer)
  }, [])

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-500 flex flex-col items-center justify-center relative overflow-hidden">
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-white/10 rounded-full animate-pulse" />
        <div className="absolute -bottom-40 -left-40 w-96 h-96 bg-white/10 rounded-full animate-pulse" style={{ animationDelay: '1s' }} />
      </div>
      <div className="relative z-10 flex flex-col items-center">
        <div className="w-28 h-28 rounded-3xl bg-white shadow-2xl shadow-black/30 flex items-center justify-center mb-8">
          <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-indigo-500 to-pink-500 flex items-center justify-center">
            <Camera className="w-10 h-10 text-white" />
          </div>
        </div>
        <h1 className="text-5xl font-bold text-white mb-4">SnapBeam</h1>
        <div className={`transition-all duration-700 ${showTagline ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'}`}>
          <p className="text-white/80 text-lg text-center max-w-xs">Send moments. Instantly live on your loved one's home screen.</p>
          <div className="flex justify-center mt-6"><Heart className="w-8 h-8 text-white animate-pulse" /></div>
        </div>
      </div>
      <div className="absolute bottom-12 flex items-center gap-2">
        <div className="w-2 h-2 bg-white rounded-full animate-bounce" style={{ animationDelay: '0ms' }} />
        <div className="w-2 h-2 bg-white rounded-full animate-bounce" style={{ animationDelay: '150ms' }} />
        <div className="w-2 h-2 bg-white rounded-full animate-bounce" style={{ animationDelay: '300ms' }} />
      </div>
    </div>
  )
}

// ============================================
// WIDGET SETUP SCREEN
// ============================================
function WidgetSetupScreen({ onComplete, onSkip }: { onComplete: () => void; onSkip: () => void }) {
  const [currentStep, setCurrentStep] = useState(0)
  const detectedOS: 'ios' | 'android' = typeof navigator !== 'undefined' && navigator.userAgent.toLowerCase().includes('android') ? 'android' : 'ios'

  const steps = [
    { title: 'Add Widget to Home Screen', description: 'See photos from your loved ones instantly.', icon: <Widget className="w-12 h-12" /> },
    { title: detectedOS === 'ios' ? 'iOS Setup' : 'Android Setup', description: 'Follow these steps to add the widget.', icon: <Smartphone className="w-12 h-12" /> },
    { title: "You're All Set!", description: 'Photos will appear on your widget automatically.', icon: <Sparkles className="w-12 h-12" /> }
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 flex flex-col">
      <div className="pt-6 px-6">
        <div className="flex justify-center gap-2">
          {steps.map((_, index) => (
            <div key={index} className={`h-2 rounded-full transition-all duration-300 ${
              index === currentStep ? 'w-8 bg-gradient-to-r from-indigo-500 to-pink-500' : index < currentStep ? 'w-2 bg-indigo-500' : 'w-2 bg-gray-300 dark:bg-gray-600'}`} />
          ))}
        </div>
      </div>
      <div className="flex-1 flex flex-col items-center justify-center px-6 py-12">
        <div className="max-w-md w-full text-center">
          <div className={`w-24 h-24 mx-auto mb-8 rounded-3xl flex items-center justify-center ${
            currentStep === 0 ? 'bg-gradient-to-br from-indigo-500 to-pink-500' :
            currentStep === 1 ? 'bg-gradient-to-br from-purple-500 to-indigo-500' : 'bg-gradient-to-br from-green-500 to-teal-500'} text-white`}>
            {steps[currentStep].icon}
          </div>
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">{steps[currentStep].title}</h2>
          <p className="text-gray-600 dark:text-gray-400 mb-8">{steps[currentStep].description}</p>
          {currentStep === 2 && (
            <div className="flex justify-center mb-8">
              <div className="w-32 h-32 rounded-full bg-gradient-to-br from-green-400 to-teal-500 flex items-center justify-center">
                <Check className="w-16 h-16 text-white" />
              </div>
            </div>
          )}
        </div>
      </div>
      <div className="p-6 space-y-3">
        <Button className="w-full h-14 text-lg bg-gradient-to-r from-indigo-500 to-pink-500" onClick={() => currentStep < steps.length - 1 ? setCurrentStep(currentStep + 1) : onComplete()}>
          {currentStep < steps.length - 1 ? <>Next Step <ArrowRight className="w-5 h-5 ml-2" /></> : <>Get Started <Sparkles className="w-5 h-5 ml-2" /></>}
        </Button>
        {currentStep < steps.length - 1 && <Button variant="ghost" className="w-full text-gray-500" onClick={onSkip}>Skip for now</Button>}
      </div>
    </div>
  )
}

// ============================================
// PREMIUM SCREEN
// ============================================
function PremiumScreen({ onBack }: { onBack: () => void }) {
  const features = [
    { icon: '∞', title: 'Unlimited Photo Sends', desc: 'No daily limits' },
    { icon: 'HD', title: 'HD Quality Photos', desc: 'Full resolution sharing' },
    { icon: '📁', title: 'Photo History', desc: '30-day photo archive' },
    { icon: '🎨', title: 'Custom Widget Themes', desc: 'Personalize your widgets' },
    { icon: '👥', title: 'Multiple Connections', desc: 'Connect with more people' },
    { icon: '⚡', title: 'Priority Support', desc: 'Fast response times' },
  ]

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
      <header className="sticky top-0 z-50 backdrop-blur-xl bg-white/80 dark:bg-gray-900/80 border-b">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={onBack}>←</Button>
          <h1 className="text-xl font-bold">Premium</h1>
        </div>
      </header>
      <div className="max-w-md mx-auto px-4 py-8">
        <div className="text-center mb-8">
          <div className="w-24 h-24 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center shadow-lg shadow-amber-500/30">
            <Diamond className="w-12 h-12 text-white" />
          </div>
          <Badge className="bg-gradient-to-r from-indigo-500 to-pink-500 text-white mb-4">Coming Soon</Badge>
          <h2 className="text-2xl font-bold mb-2">Unlock Premium Features</h2>
          <p className="text-muted-foreground">Get unlimited photo sends and more!</p>
        </div>
        <div className="space-y-3 mb-8">
          {features.map((f, i) => (
            <div key={i} className="flex items-center gap-3 p-3 rounded-xl bg-white dark:bg-gray-800 border">
              <div className="w-10 h-10 rounded-lg bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center text-lg">{f.icon}</div>
              <div className="flex-1"><p className="font-medium">{f.title}</p><p className="text-xs text-muted-foreground">{f.desc}</p></div>
              <Check className="w-5 h-5 text-amber-500" />
            </div>
          ))}
        </div>
        <Card className="bg-gradient-to-br from-amber-50 to-orange-50 dark:from-amber-950/30 dark:to-orange-950/30 border-amber-200 dark:border-amber-800">
          <CardContent className="p-4 text-center">
            <p className="text-sm text-muted-foreground mb-2">Expected Pricing</p>
            <div className="flex justify-center gap-4 mb-2">
              <div className="px-4 py-2 rounded-lg border"><p className="text-xs text-muted-foreground">Monthly</p><p className="text-xl font-bold">$2.99</p></div>
              <div className="px-4 py-2 rounded-lg bg-amber-500 text-white"><p className="text-xs opacity-80">Yearly</p><p className="text-xl font-bold">$19.99</p></div>
            </div>
            <p className="text-xs text-green-600 dark:text-green-400">Save 44% with yearly plan!</p>
          </CardContent>
        </Card>
        <Button className="w-full h-14 mt-6 bg-gradient-to-r from-amber-500 to-orange-500 text-lg" onClick={() => toast({ title: 'Coming Soon!', description: 'We\'ll notify you when Premium launches!' })}>
          <Sparkles className="w-5 h-5 mr-2" /> Notify Me When Available
        </Button>
      </div>
    </div>
  )
}

// ============================================
// WELCOME SCREEN
// ============================================
function WelcomeScreen({ onCreateConnection, onJoinConnection, joinCode, setJoinCode, isLoading }: {
  onCreateConnection: () => void; onJoinConnection: () => void; joinCode: string; setJoinCode: (c: string) => void; isLoading: boolean
}) {
  return (
    <div className="flex flex-col items-center justify-center min-h-[70vh] animate-fade-in pb-24">
      <div className="text-center mb-12">
        <div className="w-24 h-24 mx-auto mb-6 rounded-3xl bg-gradient-to-br from-indigo-500 to-pink-500 flex items-center justify-center shadow-2xl shadow-indigo-500/30 animate-pulse">
          <Heart className="w-12 h-12 text-white" />
        </div>
        <h2 className="text-3xl font-bold mb-3 bg-gradient-to-r from-indigo-600 to-pink-600 bg-clip-text text-transparent">Welcome to SnapBeam</h2>
        <p className="text-gray-600 dark:text-gray-400 max-w-md mx-auto">Send moments. Instantly live on your loved one's home screen. No accounts, no login.</p>
      </div>
      <div className="w-full max-w-md space-y-4">
        <Card className="border-2 border-indigo-200 dark:border-indigo-800 hover:border-indigo-400 transition-colors cursor-pointer" onClick={onCreateConnection}>
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 rounded-xl bg-indigo-100 dark:bg-indigo-900 flex items-center justify-center">
                <Link2 className="w-6 h-6 text-indigo-600 dark:text-indigo-400" />
              </div>
              <div className="flex-1">
                <h3 className="font-semibold text-lg">Create Connection</h3>
                <p className="text-sm text-gray-500">Generate a code to share</p>
              </div>
              {isLoading ? <Loader2 className="w-5 h-5 animate-spin text-indigo-600" /> : <Check className="w-5 h-5 text-indigo-600" />}
            </div>
          </CardContent>
        </Card>
        <div className="relative"><Separator /></div>
        <Card className="border-2 border-pink-200 dark:border-pink-800">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg flex items-center gap-2"><Users className="w-5 h-5 text-pink-600" /> Join Connection</CardTitle>
            <CardDescription>Enter a code shared with you</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex gap-2">
              <Input placeholder="Enter code" value={joinCode} onChange={(e) => setJoinCode(e.target.value.toUpperCase())} className="text-center text-lg tracking-widest font-mono" maxLength={8} />
              <Button onClick={onJoinConnection} disabled={isLoading || joinCode.length < 6} className="bg-pink-500 hover:bg-pink-600">
                {isLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : 'Join'}
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

// ============================================
// CONNECTED VIEW
// ============================================
function ConnectedView({ connection, selectedImage, setSelectedImage, caption, setCaption, isLoading, onCopyCode, copied, onSendPhoto, onImageSelect, remainingSends, usage, onShowPremium }: {
  connection: ConnectionState; selectedImage: string | null; setSelectedImage: (i: string | null) => void; caption: string; setCaption: (c: string) => void;
  isLoading: boolean; onCopyCode: () => void; copied: boolean; onSendPhoto: () => void; onImageSelect: (e: React.ChangeEvent<HTMLInputElement>) => void;
  remainingSends: number; usage: UsageData; onShowPremium: () => void
}) {
  const isUnlimited = remainingSends === -1
  const canSend = isUnlimited || remainingSends > 0

  return (
    <div className="space-y-6 pb-24">
      {/* Usage Indicator */}
      <div className={`p-3 rounded-xl ${isUnlimited ? 'bg-gradient-to-r from-amber-500 to-orange-500' : 'bg-indigo-100 dark:bg-indigo-900/30'}`}>
        <div className="flex items-center justify-center gap-2">
          {isUnlimited ? <Diamond className="w-5 h-5 text-white" /> : <Camera className="w-5 h-5 text-indigo-600 dark:text-indigo-400" />}
          <span className={`font-medium ${isUnlimited ? 'text-white' : 'text-indigo-600 dark:text-indigo-400'}`}>
            {isUnlimited ? 'Premium: Unlimited Sends' : `Free Plan: ${remainingSends} sends remaining today`}
          </span>
        </div>
      </div>

      {/* Connection Code Card */}
      <Card className="bg-gradient-to-r from-indigo-500 to-pink-500 text-white border-0">
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm opacity-80 mb-1">Your Connection Code</p>
              <span className="text-3xl font-mono font-bold tracking-wider">{connection.connectionId}</span>
            </div>
            <div className="flex gap-2">
              <Button variant="secondary" size="icon" onClick={onCopyCode}>{copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}</Button>
              <Button variant="secondary" size="icon"><Share2 className="w-4 h-4" /></Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Photo Upload Section */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2"><Camera className="w-5 h-5" /> Send a Photo</CardTitle>
          <CardDescription>Take or select a photo to share instantly</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="relative aspect-square rounded-2xl border-2 border-dashed border-gray-300 dark:border-gray-700 overflow-hidden cursor-pointer hover:border-indigo-400 transition-colors"
            onClick={() => document.getElementById('photo-input')?.click()}>
            {selectedImage ? <img src={selectedImage} alt="Selected" className="w-full h-full object-cover" /> :
              <div className="absolute inset-0 flex flex-col items-center justify-center text-gray-400">
                <Camera className="w-12 h-12 mb-2" /><p className="text-sm">Tap to add a photo</p>
              </div>}
            {selectedImage && <Button variant="destructive" size="icon" className="absolute top-2 right-2 w-8 h-8" onClick={(e) => { e.stopPropagation(); setSelectedImage(null) }}><X className="w-4 h-4" /></Button>}
          </div>
          <input id="photo-input" type="file" accept="image/*" capture="environment" className="hidden" onChange={onImageSelect} />
          <Input placeholder="Add a caption..." value={caption} onChange={(e) => setCaption(e.target.value)} />
          <Button className="w-full bg-gradient-to-r from-indigo-500 to-pink-500" disabled={!selectedImage || isLoading || !canSend} onClick={onSendPhoto}>
            {isLoading ? <><Loader2 className="w-4 h-4 mr-2 animate-spin" />Sending...</> : <><Send className="w-4 h-4 mr-2" />Send Photo</>}
          </Button>
          {!canSend && (
            <div className="p-3 rounded-xl bg-gradient-to-r from-amber-500 to-orange-500 text-white text-center cursor-pointer" onClick={onShowPremium}>
              <Diamond className="w-4 h-4 inline mr-2" />Upgrade to Premium for Unlimited Sends
            </div>
          )}
        </CardContent>
      </Card>

      {/* Last Photo Received */}
      {connection.lastPhotoBase64 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2"><ImageIcon className="w-5 h-5" /> Latest Photo</CardTitle>
            {connection.updatedAt && <CardDescription className="flex items-center gap-1"><Clock className="w-3 h-3" />{new Date(connection.updatedAt).toLocaleString()}</CardDescription>}
          </CardHeader>
          <CardContent>
            <div className="relative rounded-xl overflow-hidden">
              <img src={connection.lastPhotoBase64} alt="Last shared" className="w-full aspect-square object-cover" />
              {connection.lastCaption && <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-4"><p className="text-white text-sm">{connection.lastCaption}</p></div>}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}

// ============================================
// SETTINGS PANEL
// ============================================
function SettingsPanel({ isDarkMode, setIsDarkMode, onDisconnect, isConnected, onShowWidgetSetup, onShowPremium }: {
  isDarkMode: boolean; setIsDarkMode: (m: boolean) => void; onDisconnect: () => void; isConnected: boolean;
  onShowWidgetSetup: () => void; onShowPremium: () => void
}) {
  return (
    <div className="space-y-6 pb-24">
      <h2 className="text-2xl font-bold">Settings</h2>
      
      {/* Premium Card */}
      <Card className="bg-gradient-to-r from-amber-500 to-orange-500 text-white border-0" onClick={onShowPremium}>
        <CardContent className="p-4">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-xl bg-white/20 flex items-center justify-center">
              <Diamond className="w-6 h-6" />
            </div>
            <div className="flex-1">
              <h3 className="font-bold text-lg">Go Premium</h3>
              <p className="text-sm opacity-90">Unlimited sends & more features</p>
            </div>
            <Badge className="bg-white/20">Coming Soon</Badge>
          </div>
        </CardContent>
      </Card>

      {/* Widget Setup */}
      <Card>
        <CardHeader><CardTitle className="flex items-center gap-2"><Widget className="w-5 h-5 text-indigo-600" /> Widget Setup</CardTitle></CardHeader>
        <CardContent className="space-y-4">
          <p className="text-sm text-muted-foreground">Add the SnapBeam widget to your home screen to see photos instantly.</p>
          <Button className="w-full bg-gradient-to-r from-indigo-500 to-pink-500" onClick={onShowWidgetSetup}>Setup Widget</Button>
        </CardContent>
      </Card>

      {/* Appearance */}
      <Card>
        <CardHeader><CardTitle>Appearance</CardTitle></CardHeader>
        <CardContent>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-gray-100 dark:bg-gray-800 flex items-center justify-center">
                {isDarkMode ? <div className="w-5 h-5 rounded-full bg-gray-700" /> : <div className="w-5 h-5 rounded-full bg-yellow-400" />}
              </div>
              <div><p className="font-medium">Dark Mode</p><p className="text-sm text-muted-foreground">Switch themes</p></div>
            </div>
            <Switch checked={isDarkMode} onCheckedChange={setIsDarkMode} />
          </div>
        </CardContent>
      </Card>

      {/* Connection */}
      <Card>
        <CardHeader><CardTitle>Connection</CardTitle></CardHeader>
        <CardContent>
          <Button variant="destructive" className="w-full" disabled={!isConnected} onClick={onDisconnect}>
            <WifiOff className="w-4 h-4 mr-2" /> Disconnect
          </Button>
        </CardContent>
      </Card>

      {/* About */}
      <Card>
        <CardHeader><CardTitle>About SnapBeam</CardTitle></CardHeader>
        <CardContent className="space-y-2">
          <p className="text-sm text-muted-foreground">Send moments instantly with your loved ones. No accounts required.</p>
          <p className="text-sm text-muted-foreground">Version 1.0.0</p>
        </CardContent>
      </Card>
    </div>
  )
}
