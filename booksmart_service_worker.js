'use strict';

const CACHE_NAME = 'booksmart-offline-v5';
const PRECACHE_FILES = [
  './',
  'index.html',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'assets/AssetManifest.bin',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  'assets/packages/syncfusion_flutter_pdfviewer/assets/fonts/RobotoMono-Regular.ttf',
  'assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/highlight.png',
  'assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/squiggly.png',
  'assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/strikethrough.png',
  'assets/packages/syncfusion_flutter_pdfviewer/assets/icons/dark/underline.png',
  'assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/highlight.png',
  'assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/squiggly.png',
  'assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/strikethrough.png',
  'assets/packages/syncfusion_flutter_pdfviewer/assets/icons/light/underline.png',
  'assets/assets/images/principal_logo.jpeg',
  'assets/assets/images/ImagenLibro/LibroAnatomiaHumana.png',
  'assets/assets/images/ImagenLibro/LibroApuntesdeContabilidadFinanciera.png',
  'assets/assets/images/ImagenLibro/LibroContabilidadFinancieraIntermedia.png',
  'assets/assets/images/ImagenLibro/LibroDiagnosticoClinico.png',
  'assets/assets/images/ImagenLibro/LibroElRefinodelPetroleo.png',
  'assets/assets/images/ImagenLibro/LibroJavaScriptTheDefinitiveGuide.png',
  'assets/assets/images/ImagenLibro/LibroLugarArtificialIntelligence.png',
  'assets/assets/images/ImagenLibro/LibroMatematicasAplicadasalaIngenieriaPetrolera.png',
  'assets/assets/images/ImagenLibro/LibroObject-OrientedProgrammingWithc++.png',
  'assets/assets/images/ImagenLibro/LibroPython.png',
  'assets/assets/images/noticias/NoticiaProyecto001.jpg',
  'assets/assets/images/noticias/NoticiaProyecto002.jpg',
  'assets/assets/images/noticias/NoticiaProyecto003.jpg',
  'assets/assets/images/noticias/NoticiaProyecto004.jpg',
  'assets/assets/images/noticias/NoticiaProyecto005.jpg',
  'assets/assets/images/noticias/NoticiaProyecto006.jpg',
  'assets/assets/PdfLibro/Anatomia_Humana.pdf',
  'assets/assets/PdfLibro/Apuntes_de_Contabilidad_Financiera.pdf',
  'assets/assets/PdfLibro/Artificial_Intelligence.pdf',
  'assets/assets/PdfLibro/Contabilidad_Financiera_Intermedia.pdf',
  'assets/assets/PdfLibro/Diagnostico_Clinico_Ciencia_y_Arte.pdf',
  'assets/assets/PdfLibro/El_Refino_del_Petroleo.pdf',
  'assets/assets/PdfLibro/JavaScript_The_Definitive_Guide.pdf',
  'assets/assets/PdfLibro/Matematicas_Aplicadas_Ingenieria_Petrolera.pdf',
  'assets/assets/PdfLibro/Object_Oriented_Programming_with_Cpp.pdf',
  'assets/assets/PdfLibro/Python_The_Complete_Reference.pdf',
  'assets/assets/ImagenQR/AnatomiaHumanaQR.png',
  'assets/assets/ImagenQR/ApuntesContabilidadFinancieraQR.png',
  'assets/assets/ImagenQR/ArtificialIntelligenceQR.png',
  'assets/assets/ImagenQR/ContabilidadFinancieraIntermediaQR.png',
  'assets/assets/ImagenQR/DiagnosticoClinicoQR.png',
  'assets/assets/ImagenQR/ElRefinoDelPetroleoQR.png',
  'assets/assets/ImagenQR/JavaScriptDefinitiveGuideQR.png',
  'assets/assets/ImagenQR/MatematicasIngenieriaPetroleraQR.png',
  'assets/assets/ImagenQR/ObjectOrientedProgrammingCppQR.png',
  'assets/assets/ImagenQR/PythonQR.png',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(CACHE_NAME)
      .then((cache) =>
        cache.addAll(
          PRECACHE_FILES.map((path) => new URL(path, self.registration.scope)),
        ),
      )
      .then(() => self.skipWaiting())
      .catch((error) => {
        console.error('BookSmart offline assets could not be cached:', error);
        throw error;
      }),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((cacheNames) =>
        Promise.all(
          cacheNames
            .filter(
              (cacheName) =>
                cacheName.startsWith('booksmart-offline-') &&
                cacheName !== CACHE_NAME,
            )
            .map((cacheName) => caches.delete(cacheName)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const requestUrl = new URL(request.url);
  if (request.method !== 'GET' || requestUrl.origin !== self.location.origin) {
    return;
  }

  event.respondWith(
    fetch(request)
      .then((response) => {
        if (!response.ok) {
          return response;
        }
        return caches
          .open(CACHE_NAME)
          .then((cache) => cache.put(request, response.clone()))
          .then(
            () => response,
            (error) => {
              console.warn('BookSmart response could not be cached:', error);
              return response;
            },
          );
      })
      .catch(async () => {
        const cachedResponse = await caches.match(request, {
          ignoreSearch: true,
        });
        if (cachedResponse) {
          return cachedResponse;
        }
        if (request.mode === 'navigate') {
          const appShell = await caches.match(
            new URL('./', self.registration.scope),
          );
          if (appShell) {
            return appShell;
          }
        }
        return Response.error();
      }),
  );
});
