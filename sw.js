/* Service Worker · Just Go · Canaã Junina 2026 */
const CACHE = 'canaa-junina-v0.7.4';
const ASSETS = [
  './',
  './index.html',
  './dashboard.html',
  './relatorios.html',
  'https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:ital,wght@0,300;0,400;0,500;0,600;1,300&display=swap'
];

// instalar: cachear os arquivos essenciais
self.addEventListener('install', e=>{
  e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)).then(()=>self.skipWaiting()));
});

// ativar: limpar caches antigos
self.addEventListener('activate', e=>{
  e.waitUntil(caches.keys().then(keys=>
    Promise.all(keys.filter(k=>k!==CACHE).map(k=>caches.delete(k)))
  ).then(()=>self.clients.claim()));
});

// fetch: cache-first para assets; rede para o Supabase (nunca cachear API)
self.addEventListener('fetch', e=>{
  const url = e.request.url;
  // chamadas ao Supabase sempre vão para a rede (dados frescos)
  if(url.includes('supabase.co')){
    return; // deixa o navegador lidar normalmente
  }
  // index.html e navegação: network-first (sempre versão nova se houver internet)
  const isHTML = e.request.mode === 'navigate' || url.endsWith('index.html') || url.endsWith('/junina/') || url.endsWith('/');
  if(isHTML){
    e.respondWith(
      fetch(e.request).then(resp=>{
        const clone = resp.clone();
        caches.open(CACHE).then(c=>c.put(e.request, clone));
        return resp;
      }).catch(()=> caches.match(e.request).then(c=> c || caches.match('./index.html')))
    );
    return;
  }
  // demais assets: cache-first
  e.respondWith(
    caches.match(e.request).then(cached=> cached || fetch(e.request).then(resp=>{
      if(e.request.method==='GET' && resp.status===200){
        const clone = resp.clone();
        caches.open(CACHE).then(c=>c.put(e.request, clone));
      }
      return resp;
    }).catch(()=>cached))
  );
});
