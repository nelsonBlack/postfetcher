self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open("post-cache").then((cache) => {
      return cache.addAll([
        "./",
        "main.dart.js",
        "index.html",
        "manifest.json",
        "assets/fonts/MaterialIcons-Regular.otf",
        "assets/AssetManifest.json",
        "assets/FontManifest.json",
      ])
    })
  )
})

self.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request)
    })
  )
})
