import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Enable standalone output for Docker deployment
  output: 'standalone',

  // Proxy API requests to backend container
  async rewrites() {
    return [
      {
        source: '/api/v1/:path*',
        destination: 'http://backend:8088/api/v1/:path*',
      },
    ];
  },

  images: {
    // Enable modern image formats for better compression
    formats: ['image/avif', 'image/webp'],
    // Configure remote image domains (add your S3/CDN domains here)
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**',
      },
      {
        protocol: 'http',
        hostname: '**',
      },
    ],
    // Device sizes for responsive images
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048],
    // Image sizes for the sizes attribute
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    // Minimum cache TTL for optimized images (in seconds)
    minimumCacheTTL: 60 * 60 * 24, // 24 hours
    // Allow localhost and private IPs for development
    dangerouslyAllowSVG: true,
    dangerouslyAllowLocalIP: true,

  },
  // Allow localhost images in development
  allowedDevOrigins: ['localhost', '127.0.0.1'],
};

export default nextConfig;
