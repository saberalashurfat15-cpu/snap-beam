/**
 * SnapBeam Cloudflare Worker
 * Backend API for photo sharing with KV storage and R2
 * 
 * Endpoints:
 * - POST /create - Create new connection
 * - POST /update - Update photo for connection
 * - GET /latest - Get latest photo for connection
 * - POST /upload - Upload photo to R2
 */

// CORS headers for all responses
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

// Generate random connection code
function generateConnectionCode(length = 8) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// JSON response helper
function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders,
    },
  });
}

// Error response helper
function errorResponse(message, status = 400) {
  return jsonResponse({ error: message }, status);
}

export default {
  async fetch(request, env, ctx) {
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);
    const path = url.pathname;

    try {
      // Route: Create new connection
      if (path === '/create' && request.method === 'POST') {
        const connectionId = generateConnectionCode(8);
        const connectionData = {
          connection_id: connectionId,
          last_photo_url: null,
          last_caption: null,
          last_photo_base64: null,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        };

        await env.SNAPBEAM_KV.put(
          `connection:${connectionId}`,
          JSON.stringify(connectionData)
        );

        return jsonResponse({
          success: true,
          connection_id: connectionId,
          message: 'Connection created successfully',
        });
      }

      // Route: Update photo for connection
      if (path === '/update' && request.method === 'POST') {
        const body = await request.json();
        const { connection_id, photo_url, caption, photo_base64 } = body;

        if (!connection_id) {
          return errorResponse('connection_id is required');
        }

        // Check if connection exists
        const existingData = await env.SNAPBEAM_KV.get(
          `connection:${connection_id}`
        );

        if (!existingData) {
          return errorResponse('Connection not found', 404);
        }

        const connectionData = JSON.parse(existingData);
        
        // Update connection data
        if (photo_url) connectionData.last_photo_url = photo_url;
        if (photo_base64) connectionData.last_photo_base64 = photo_base64;
        if (caption !== undefined) connectionData.last_caption = caption;
        connectionData.updated_at = new Date().toISOString();

        await env.SNAPBEAM_KV.put(
          `connection:${connection_id}`,
          JSON.stringify(connectionData)
        );

        return jsonResponse({
          success: true,
          message: 'Photo updated successfully',
          updated_at: connectionData.updated_at,
        });
      }

      // Route: Get latest photo
      if (path === '/latest' && request.method === 'GET') {
        const connectionId = url.searchParams.get('connection_id');

        if (!connectionId) {
          return errorResponse('connection_id parameter is required');
        }

        const data = await env.SNAPBEAM_KV.get(`connection:${connectionId}`);

        if (!data) {
          return errorResponse('Connection not found', 404);
        }

        const connectionData = JSON.parse(data);
        
        return jsonResponse({
          success: true,
          connection_id: connectionData.connection_id,
          last_photo_url: connectionData.last_photo_url,
          last_photo_base64: connectionData.last_photo_base64,
          last_caption: connectionData.last_caption,
          updated_at: connectionData.updated_at,
        });
      }

      // Route: Upload photo to R2
      if (path === '/upload' && request.method === 'POST') {
        const formData = await request.formData();
        const file = formData.get('photo');
        const connectionId = formData.get('connection_id');

        if (!file || !connectionId) {
          return errorResponse('photo and connection_id are required');
        }

        // Generate unique filename
        const timestamp = Date.now();
        const extension = file.name.split('.').pop() || 'jpg';
        const filename = `${connectionId}/${timestamp}.${extension}`;

        // Upload to R2
        await env.SNAPBEAM_R2.put(filename, file.stream(), {
          httpMetadata: {
            contentType: file.type,
          },
        });

        // Generate public URL (assuming public bucket)
        const photoUrl = `https://your-r2-bucket.your-domain.com/${filename}`;

        // Update connection
        const existingData = await env.SNAPBEAM_KV.get(
          `connection:${connectionId}`
        );
        const connectionData = existingData 
          ? JSON.parse(existingData)
          : { connection_id: connectionId, created_at: new Date().toISOString() };

        connectionData.last_photo_url = photoUrl;
        connectionData.updated_at = new Date().toISOString();

        await env.SNAPBEAM_KV.put(
          `connection:${connectionId}`,
          JSON.stringify(connectionData)
        );

        return jsonResponse({
          success: true,
          photo_url: photoUrl,
          message: 'Photo uploaded successfully',
        });
      }

      // Route: Delete connection
      if (path === '/delete' && request.method === 'POST') {
        const body = await request.json();
        const { connection_id } = body;

        if (!connection_id) {
          return errorResponse('connection_id is required');
        }

        await env.SNAPBEAM_KV.delete(`connection:${connection_id}`);

        return jsonResponse({
          success: true,
          message: 'Connection deleted successfully',
        });
      }

      // Route: Health check
      if (path === '/health') {
        return jsonResponse({
          success: true,
          message: 'SnapBeam API is running',
          timestamp: new Date().toISOString(),
        });
      }

      // 404 for unknown routes
      return errorResponse('Not found', 404);

    } catch (error) {
      console.error('Worker error:', error);
      return errorResponse('Internal server error', 500);
    }
  },
};
