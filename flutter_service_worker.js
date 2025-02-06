'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "e523b49f7ac3d52fa2a74629c7ae09b1",
"assets/AssetManifest.bin.json": "92bac98a41636ccb26988770f7cb09e1",
"assets/AssetManifest.json": "b86d04af7b317324219bbdb15a895f80",
"assets/assets/icons/twitter_x.svg": "c8aee024b72e86e9972cd1ba3deffa32",
"assets/assets/images/BTH_1.png": "d7e3240ab5c8adab42f884dbe72e5a47",
"assets/assets/images/BTH_2.png": "e03d13687c52f4e97c4970fbc8b72509",
"assets/assets/images/BTH_3.png": "c9d1a4cd5faa090ced10af77aedab899",
"assets/assets/images/BTH_4.png": "bec54ad986cd6ea8672a33a5a5fca823",
"assets/assets/images/Kangchenjunga_520_km.jpg": "608b7bd1d51cfd954419bd4ba9b35cdf",
"assets/assets/info/diagram_spec.json": "9d1593d67f05f86d89c6f8f311b4e55b",
"assets/assets/info/diagram_spec_external.json": "c3611291587d2ba63e8043ea6b317bdb",
"assets/assets/info/diagram_spec_old.json": "9a3bc30d1f063c5ae8a3893a4f579aa5",
"assets/assets/info/field_info.json": "f69bf8fbcda14d0421acc4f546c3e5bc",
"assets/assets/info/id_type.csv": "7742b09b7b0ed15a7f83397e96cc6259",
"assets/assets/info/menu_items.json": "3c97fb53eacc2b3749bbe0a7e9a11300",
"assets/assets/info/presets.json": "815796370c9441f0c4b97058f38771b3",
"assets/assets/observer.png": "88f222844700b212a65200613f4feff3",
"assets/assets/slides/README.md": "4401df8f7bb9e3b48e5c8192b9500d82",
"assets/assets/source_file.svg": "8a2a6f5d60af5330165a058155f3e9b5",
"assets/assets/svg/BTH_1.svg": "35c2d1464e1d460ba1774f07dfd41785",
"assets/assets/svg/BTH_2.svg": "bc1b49bba253faea10dc1b2bee9eba55",
"assets/assets/svg/BTH_3.svg": "a4e891845f67b36d7c5e4e8c1c891908",
"assets/assets/svg/BTH_4.svg": "7cdeb214f44a71ea0ea9bdf898f49671",
"assets/assets/svg/BTH_viewBox_diagram1.svg": "745a4564c625d78496d78c31eb1922eb",
"assets/assets/svg/BTH_viewBox_diagram2.svg": "e95a8e788ac31060c067907183abac19",
"assets/assets/svg/BTH_viewBox_diagram2_backup.svg": "9a39d813eec91c104daa0159cb719b5c",
"assets/assets/svg/BTH_viewBox_diagram2_save_Latest.svg": "b8f272e32098420079860d66a30366c5",
"assets/assets/svg/BTH_viewBox_diagram2_save_Latest2.svg": "a43a608fe1ddd7b0a5a9991188f0cd53",
"assets/assets/svg/BTH_viewBox_diagram_backup.svg": "745a4564c625d78496d78c31eb1922eb",
"assets/assets/svg_diagram.svg": "f790e3d743831a96cc13707dd2157dcd",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "2d1f6e73b5618b10dd53364f2023105d",
"assets/NOTICES": "abf4bd0ab538d0921050af4290ed1847",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/social_preview.png": "428e47a340b459341ec77c65942a3b34",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "ef6f51d005dde33824532c166c395d0e",
"favicon_old.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "adf0acc089e0b1f98d5b9da3fed23680",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "70571876d4f92f760a6bdf26fdaad6ed",
"/": "70571876d4f92f760a6bdf26fdaad6ed",
"main.dart.js": "11241fc4be03030dad11110779875cad",
"manifest.json": "a75d6d85551ce9e864e0e73c5c8fd399",
"robots.txt": "ea5d43b0e323a6f4a56712be1621c72a",
"version.json": "dd4c2417be8def716208be9f6e462725"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
