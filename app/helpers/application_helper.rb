module ApplicationHelper
  def default_meta_tags
    {
      site: "Game Exit",
      reverse: true,
      charset: 'utf-8',
      title: "ゲーム時間の適切な管理をサポートするサービス",
      description: 'ゲームの時間管理を効率的にサポートするプラットフォームです',
      separator: '|',
      keywords: 'ゲーム,時間管理',
      canonical: ENV.fetch('APP_URL', 'http://localhost:3000'),
      og:{
        site_name: "Game Exit",
        title: "ゲーム時間の適切な管理をサポートするサービス",
        description: 'ゲームの時間管理を効率的にサポートするプラットフォームです',
        type: 'website',
        url: ENV.fetch('APP_URL', 'http://localhost:3000'),
        image: image_url('ogp.png'),
        locale: 'ja_JP'
      },
      twitter: {
        card: 'summary_large_image',
        title: "ゲーム時間の適切な管理をサポートするサービス",
        description: 'ゲームの時間管理を効率的にサポートするプラットフォームです',
        image: image_url('ogp.png')
      }
    }
  end
end
