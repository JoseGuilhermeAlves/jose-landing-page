'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "02cfc4517d45df1d62eddd6bdb1debae",
"assets/AssetManifest.bin.json": "1cf673dc52a6ce7f35615fe24ed4b3b2",
"assets/assets/fonts/IBMPlexSans-Bold.ttf": "9c3c89006de053b78de37a6b20a0d1e9",
"assets/assets/fonts/IBMPlexSans-Medium.ttf": "46ca4f803eb119edaaef4b928dec7ce7",
"assets/assets/fonts/IBMPlexSans-Regular.ttf": "4bc2240b8b83d97b8a9415f7cbaf56db",
"assets/assets/fonts/IBMPlexSans-SemiBold.ttf": "f75f5cc52c38dc7a331619fa4a8b32d5",
"assets/assets/images/foto_perfil.jpg": "549f09a9b16a7d166f89709d7d0221f1",
"assets/assets/images/foto_recortada.webp": "8dc5ffd10d48da78698c96eacda042f1",
"assets/assets/images/tengu_icon.png": "73370cb7089b3df122dd8042ee80a642",
"assets/FontManifest.json": "9ea7d29f3942430bdd054afabf5b8763",
"assets/fonts/MaterialIcons-Regular.otf": "4d249a39ecb84d82a41246c4484668a5",
"assets/NOTICES": "92905f59a6ef075429392c4e024620ff",
"assets/packages/animations/assets/images/oni_boss.png": "d40c1f4142e5d5b5e309595e45b84741",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/feature_showcase/assets/delivery/alface.webp": "a2a24c7f64e7463dd5bbac9736d2e8fa",
"assets/packages/feature_showcase/assets/delivery/azeite.webp": "a5a233bafb34baa59449182e318b78e4",
"assets/packages/feature_showcase/assets/delivery/baguete.webp": "7943ecf9cd6d3d5ba01d91df9dc73d2f",
"assets/packages/feature_showcase/assets/delivery/banana.webp": "0f293cb858d2b29b5996d4b5df9d7862",
"assets/packages/feature_showcase/assets/delivery/banca_hortifruti.webp": "3e931e39bfcf03db18aafc970b54e73c",
"assets/packages/feature_showcase/assets/delivery/caixote.webp": "ed028702bd012d494e9d92e8e22bec36",
"assets/packages/feature_showcase/assets/delivery/cenoura.webp": "9c17fc8e378d64d9cdcfb1f907a6c349",
"assets/packages/feature_showcase/assets/delivery/emporio.webp": "67e3b534e0bd2e7bbd463ab2465d123f",
"assets/packages/feature_showcase/assets/delivery/feijao.webp": "87ea7a05c7ec4efb344506b3fcb4bb9c",
"assets/packages/feature_showcase/assets/delivery/feira.webp": "e86f8659c28873842f7a2942d4ccadc4",
"assets/packages/feature_showcase/assets/delivery/laranja.webp": "4847c0d81e26a6d63c26aeb79f9d1907",
"assets/packages/feature_showcase/assets/delivery/maca.webp": "195e0693cebe92fbeab1023a990ebd05",
"assets/packages/feature_showcase/assets/delivery/manteiga.webp": "e049de96f9879ad154054967aa74962b",
"assets/packages/feature_showcase/assets/delivery/padaria.webp": "f9ce9a41bb56cc1001c3a0fc99aa8dff",
"assets/packages/feature_showcase/assets/delivery/padoca.webp": "54e53ff5ee12a44b027d8442ffe8f5a5",
"assets/packages/feature_showcase/assets/delivery/pao_doce.webp": "03186e802b6bc9e1b939d9fcdea027b1",
"assets/packages/feature_showcase/assets/delivery/pao_frances.webp": "36edab6c30960e6ac30615f9e7c123a2",
"assets/packages/feature_showcase/assets/delivery/queijaria.webp": "b86a23e9a8c29202c333c69e46102ebf",
"assets/packages/feature_showcase/assets/delivery/queijo_minas.webp": "3e728f32b667dad4d5f6ddca85dcb59f",
"assets/packages/feature_showcase/assets/delivery/tomate.webp": "c9bb79fef01b3bf862472749f99a024b",
"assets/packages/feature_showcase/assets/realestate/apto_praca_cozinha.webp": "35b62a2e068d0a35308e4724ae2c9abd",
"assets/packages/feature_showcase/assets/realestate/apto_praca_fachada.webp": "96de7f64e41c8f32971dc9f79e020310",
"assets/packages/feature_showcase/assets/realestate/apto_praca_sala.webp": "f70d50ac7e0d0fd842732a77c8e72206",
"assets/packages/feature_showcase/assets/realestate/casa_atibaia_frente.webp": "a2157ed0fca18b0827ca6db216a6bc37",
"assets/packages/feature_showcase/assets/realestate/casa_atibaia_topo.webp": "c4f1291bc9b0b2f4a299ea80021f778b",
"assets/packages/feature_showcase/assets/realestate/casa_atibaia_varanda.webp": "69bddf3e92d6f9710b003b0da65435c0",
"assets/packages/feature_showcase/assets/realestate/casa_centro_historico_frente.webp": "2027679e63e3fc2a8971cfce7a97e851",
"assets/packages/feature_showcase/assets/realestate/casa_centro_historico_lateral.webp": "ba8abe118150f8aac4220c9b8ac8d111",
"assets/packages/feature_showcase/assets/realestate/casa_centro_historico_topo.webp": "e9066766184775c0f7bf38ab5a9e6284",
"assets/packages/feature_showcase/assets/realestate/casa_familiar_frente.webp": "4c12722a9d33cbb3a956aec88c9f7f55",
"assets/packages/feature_showcase/assets/realestate/casa_familiar_topo.webp": "db7c80b96f1ea145a4b8137873744d63",
"assets/packages/feature_showcase/assets/realestate/casa_familiar_varanda.webp": "54ba65c367b6961f7aef54508fe20574",
"assets/packages/feature_showcase/assets/realestate/chacara_itu_frente.webp": "fbf7f4b58c6ada76dd02ca8865ccbc4e",
"assets/packages/feature_showcase/assets/realestate/chacara_itu_piscina.webp": "4facc5a2ab8b2358431647abab844778",
"assets/packages/feature_showcase/assets/realestate/chacara_itu_topo.webp": "ce0148622430a2f7d555ea07d1f458bb",
"assets/packages/feature_showcase/assets/realestate/chacara_joanopolis_frente.webp": "111c79ee6ea28040a9742a28c8c1ec60",
"assets/packages/feature_showcase/assets/realestate/chacara_joanopolis_lago.webp": "b8c093c82c13ae87a421e51cc3b09634",
"assets/packages/feature_showcase/assets/realestate/chacara_joanopolis_topo.webp": "4ab404eb040a251cfa0de0ed81bb5803",
"assets/packages/feature_showcase/assets/realestate/corretor_carlos.webp": "399bc5e54e2b95a91cb2b11f8e7ffd93",
"assets/packages/feature_showcase/assets/realestate/corretor_maria.webp": "1e7dc30ee7ee497100a1c9393e8bd548",
"assets/packages/feature_showcase/assets/realestate/corretor_renata.webp": "50c147573d626c16f617e69368dd5d58",
"assets/packages/feature_showcase/assets/realestate/sobrado_vila_nova_frente.webp": "608662b7e8c806fcd3345b4503dbd80b",
"assets/packages/feature_showcase/assets/realestate/sobrado_vila_nova_lateral.webp": "f61cb4047fa6cd9a672b6098bbd596aa",
"assets/packages/feature_showcase/assets/realestate/sobrado_vila_nova_topo.webp": "833a652075e0ed8f0d016f533786ff74",
"assets/packages/feature_showcase/assets/realestate/studio_centro_interior.webp": "acc9476c51d514e7bb87e3f56b6bb688",
"assets/packages/feature_showcase/assets/realestate/studio_centro_janela.webp": "7ce2e5cb3f2372abd63b9efb58f73801",
"assets/packages/feature_showcase/assets/realestate/studio_centro_predio.webp": "9b1564b25b2bd31ab3d37796777a8d20",
"assets/packages/feature_showcase/assets/realestate/terreno_mata_velha_frente.webp": "8ed4f59b86b0b72993c2d66df35bea9c",
"assets/packages/feature_showcase/assets/realestate/terreno_mata_velha_fundo.webp": "ffb7d059309020a76a86f2bce28e4a08",
"assets/packages/feature_showcase/assets/realestate/terreno_mata_velha_topo.webp": "64f817dd8ef980608bc0204f38fc304f",
"assets/packages/feature_showcase/assets/realestate/terreno_vista_alegre_frente.webp": "f52a8ffbac4902449bbf93cfb5cf89e0",
"assets/packages/feature_showcase/assets/realestate/terreno_vista_alegre_serra.webp": "ee272db4e1ecee868d8caac854b0ef6b",
"assets/packages/feature_showcase/assets/realestate/terreno_vista_alegre_topo.webp": "b5ccbf207693b2bf0f192136cc027faf",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"CNAME": "b87c09a3ec8830aea9f76df183e4ab58",
"cv/jose-guilherme-alves-en.pdf": "5d27178f8efb03d87260f663782753e1",
"cv/jose-guilherme-alves-pt.pdf": "41bf9f47a50f75874c404f4e10605060",
"favicon.png": "cac024e03f95350dea15bc58f70ae2d1",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "ab231d727f9156fbf5616bf8ecbd0862",
"icons/Icon-192.png": "41dec78c643c22305ee1043bde3b81fa",
"icons/Icon-512.png": "ea4e893cfb09dde03685f5f01e249e45",
"icons/Icon-maskable-192.png": "41dec78c643c22305ee1043bde3b81fa",
"icons/Icon-maskable-512.png": "ea4e893cfb09dde03685f5f01e249e45",
"index.html": "e7df4e27646a1e6b54fd50b36993274a",
"/": "e7df4e27646a1e6b54fd50b36993274a",
"main.dart.js": "0d6cb80c4856a4207c74922f059081fa",
"main.dart.mjs": "63da1635f2d3d151c1e756be436cde78",
"main.dart.wasm": "8ea5660a89014c4f3d48fd060c22a37d",
"main.dart.wasm.map": "99ceaedf17bb4384aee8802ddb25192b",
"manifest.json": "c1d1acd5821da9f29987c988951d8c5a",
"robots.txt": "307d0d2ea54047ee7eff1c2c42c51655",
"sitemap.xml": "76c0623925bf2a4f1f96f36b184db5d8",
"version.json": "85c151ddf57e6e3d7929177dd1a665c5"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"main.dart.wasm",
"main.dart.mjs",
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
