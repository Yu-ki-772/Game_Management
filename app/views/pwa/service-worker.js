self.addEventListener('install', function(event) {
  console.log('Service Worker installing.');
});

self.addEventListener('activate', function(event) {
  console.log('Service Worker activated.');
});

self.addEventListener('fetch', function(event) {
  console.log('Fetching:', event.request.url);
});

// サーバーからプッシュ通知が届いたときに発火する
self.addEventListener('push', function(event) {
  const data = event.data ? event.data.json() : { title: '通知', body: '' };

  event.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: data.icon,
      data: { url: data.url }
    })
  );
});

// 通知クリック/タップ時の処理
self.addEventListener('notificationclick', function(event) {
  console.log('通知をクリック');
  event.notification.close();

  const url = event.notification.data?.url || '/';

  event.waitUntil(
    clients.openWindow(url)
  );
});