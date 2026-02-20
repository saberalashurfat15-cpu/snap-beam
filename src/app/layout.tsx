import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { Toaster } from "@/components/ui/toaster";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "SnapBeam - Send Moments Instantly",
  description: "Send moments. Instantly live on your loved one's home screen. No accounts, no login - just private connection codes.",
  keywords: ["SnapBeam", "Photo Sharing", "Home Screen Widget", "Family Photos", "Instant Sharing", "No Account"],
  authors: [{ name: "SnapBeam Team" }],
  icons: {
    icon: "/logo.svg",
  },
  openGraph: {
    title: "SnapBeam - Send Moments Instantly",
    description: "Send moments. Instantly live on your loved one's home screen.",
    url: "https://snapbeam.app",
    siteName: "SnapBeam",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "SnapBeam - Send Moments Instantly",
    description: "Send moments. Instantly live on your loved one's home screen.",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased bg-background text-foreground`}
      >
        {children}
        <Toaster />
      </body>
    </html>
  );
}
