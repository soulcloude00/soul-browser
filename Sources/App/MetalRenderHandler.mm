#include "MetalRenderHandler.h"

#include <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>
#if __has_include(<libyuv/convert.h>)
#include <libyuv/convert.h>
#endif

MetalRenderHandler::MetalRenderHandler(CAMetalLayer* metalLayer)
    : metalLayer_(metalLayer) {
  device_ = MTLCreateSystemDefaultDevice();
  metalLayer_.device = device_;
  metalLayer_.pixelFormat = MTLPixelFormatBGRA8Unorm;
  metalLayer_.framebufferOnly = NO;
  commandQueue_ = [device_ newCommandQueue];
}

void MetalRenderHandler::SetViewSize(int width, int height) {
  viewWidth_ = width;
  viewHeight_ = height;
  if (metalLayer_) {
    metalLayer_.drawableSize = CGSizeMake(width, height);
  }
}

void MetalRenderHandler::GetViewRect(CefRefPtr<CefBrowser> browser,
                                     CefRect& rect) {
  rect = CefRect(0, 0, viewWidth_, viewHeight_);
}

void MetalRenderHandler::CreateTexture(int width, int height) {
  if (texture_ && texture_.width == width && texture_.height == height) {
    return;
  }
  MTLTextureDescriptor* desc =
      [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                           width:width
                                                          height:height
                                                       mipmapped:NO];
  desc.usage = MTLTextureUsageShaderRead | MTLTextureUsageRenderTarget;
  texture_ = [device_ newTextureWithDescriptor:desc];
}

void MetalRenderHandler::OnPaint(CefRefPtr<CefBrowser> browser,
                                   PaintElementType type,
                                   const RectList& dirtyRects,
                                   const void* buffer,
                                   int width,
                                   int height) {
  if (!metalLayer_ || !device_ || width == 0 || height == 0) return;

  CreateTexture(width, height);
  if (!texture_) return;

  // CEF gives us a BGRA buffer; upload it straight to the Metal texture.
  MTLRegion region = {{0, 0, 0}, {static_cast<NSUInteger>(width),
                                    static_cast<NSUInteger>(height), 1}};
  [texture_ replaceRegion:region
              mipmapLevel:0
                withBytes:buffer
              bytesPerRow:width * 4];

  // Draw the texture into the current drawable.
  id<CAMetalDrawable> drawable = [metalLayer_ nextDrawable];
  if (!drawable) return;

  MTLRenderPassDescriptor* pass = [MTLRenderPassDescriptor renderPassDescriptor];
  pass.colorAttachments[0].texture = drawable.texture;
  pass.colorAttachments[0].loadAction = MTLLoadActionClear;
  pass.colorAttachments[0].storeAction = MTLStoreActionStore;
  pass.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1);

  id<MTLCommandBuffer> cmd = [commandQueue_ commandBuffer];
  id<MTLRenderCommandEncoder> enc = [cmd renderCommandEncoderWithDescriptor:pass];

  // Simple blit from source texture to drawable.
  // In production you'd use a full-screen textured quad pipeline.
  [enc endEncoding];

  id<MTLBlitCommandEncoder> blit = [cmd blitCommandEncoder];
  [blit copyFromTexture:texture_
          sourceSlice:0
          sourceLevel:0
         sourceOrigin:MTLOriginMake(0, 0, 0)
           sourceSize:MTLSizeMake(width, height, 1)
            toTexture:drawable.texture
     destinationSlice:0
     destinationLevel:0
    destinationOrigin:MTLOriginMake(0, 0, 0)];
  [blit endEncoding];

  [cmd presentDrawable:drawable];
  [cmd commit];
}

void MetalRenderHandler::OnAcceleratedPaint(
    CefRefPtr<CefBrowser> browser,
    PaintElementType type,
    const RectList& dirtyRects,
    const CefAcceleratedPaintInfo& info) {
  // For true zero-copy on Apple Silicon we'd import the IOSurface here.
  // This stub keeps the build green; full IOSurface sharing is a follow-up.
}
