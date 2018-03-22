# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
admin = User.create(email: 'admin@example.com', password: 'password', password_confirmation: 'password', name: "Admin")
User.create(email: 'user2@example.com', password: 'password', password_confirmation: 'password', name: "User2")

admin.add_role(:admin)

new_release = Release.create!(
  title: 'Works Well With Others',
  artist: "Claude VonStroke, Will Clarke, Sébastien V",
  catalog: 'DB157',
  text: "<p>2016 was a banner year for Dirtybird’s founder, Claude VonStroke. He debuted his Get Real alias with Green Velvet in the winter, and followed up with another number one single in the spring with “The Rain Break”.",
  image_url: 'https://birdfeed-dev.s3.amazonaws.com/uploads/release-images/4dc22b70-b079-489c-9d42-594d4f62dc48/WorksWellWithOthers.jpg',
  facebook_img: 'https://birdfeed-dev.s3.amazonaws.com/uploads/facebook-images/18/ae2ea0be7c11e79b5f6f59ff01eb9b/Works Well With Others - Claude VonStroke Will Clarke Sbastien V - Dirtybird.jpg',
  created_at: DateTime.current - 2.hours,
  published_at: DateTime.current - 1.hour,
  upc_code: '5054283109788',
  compilation: false,
  release_date: Time.zone.today
)

new_release_track_1 = Track.create!(
  title: 'Tiny Tambourine',
  release_id: new_release.id,
  created_at: DateTime.current - 2.hours,
  artist: "Claude VonStroke, Will Clarke, Sébastien V",
  track_number: 1,
  genre: 'Tech House',
  isrc_code: 'GBKQU1766270',
  url: 'https://birdfeed-dev.s3.amazonaws.com/uploads/tracks/334d3596-b2a5-4a45-ae6c-dbcbb7371a34/01. Claude VonStroke Will Clarke - Tiny Tambourine - Dirtybird.wav',
  sample_uri: 'https://birdfeed-dev.s3.amazonaws.com/tracks/0e/a2bad0be7b11e7ba9db561d1f7f74b/01. Claude VonStroke Will Clarke Sbastien V - Tiny Tambourine - Sample - Dirtybird.mp3'
)

new_release_track_2 = Track.create!(
  title: 'Daylight Dark Room',
  release_id: new_release.id,
  created_at: DateTime.current - 2.hours,
  artist: "Claude VonStroke, Will Clarke, Sébastien V",
  track_number: 2,
  genre: 'Tech House',
  isrc_code: 'GBKQU1766271',
  url: 'https://birdfeed-dev.s3.amazonaws.com/uploads/tracks/032c82d8-2ae1-4308-80f5-8aa408d66428/02. Claude VonStroke Sbastien V - Daylight Dark Room - Dirtybird.wav',
  sample_uri: 'https://birdfeed-dev.s3.amazonaws.com/tracks/0f/b626a0be7b11e7b306db55070250ba/02. Claude VonStroke Will Clarke Sbastien V - Daylight Dark Room - Sample - Dirtybird.mp3'
)

# Create recent post
Post.create!(
  title: 'New Announcement!',
  text: "Some text",
  created_at: DateTime.current - 3.hours,
  published_at: DateTime.current - 3.hours,
  image_url: 'http://via.placeholder.com/500/008800/ffffff.png?text=New%20Post'
)

# Create old post
Post.create!(
  title: 'Old Announcement!',
  text: "Some text",
  created_at: DateTime.current - 1.year,
  published_at: DateTime.current - 1.year,
  image_url: 'http://via.placeholder.com/500/880000/ffffff.png?text=Old%20Post'
)

# Create Topics
3.times do |i|
  Topic.create!(
    title: "Topic #{i}",
    text: "Some text",
    user_id: User.all.sample.id,
    created_at: DateTime.current - 10.hours + i.hours,
    updated_at: DateTime.current - 10.hours + i.hours,
    pinned: (i == 3) ? true : false,
    locked: (i == 1) ? true : false
  )
end

