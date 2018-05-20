# add gem 'bulk_insert'
# add bird_old_db, bird_new_db models
# run migration
namespace :bird_data do
  desc "migrate data from old database"
  task merge: :environment do

    BirdOldMerge.users

    # BirdOldMerge.releases
    # BirdOldMerge.drip_releases
    # BirdOldMerge.release_files

    BirdOldMerge.tracks
    BirdOldMerge.track_files
    # BirdOldMerge.drip_tracks
    
    # BirdOldMerge.topics
    # BirdOldMerge.topic_tags
    # BirdOldMerge.topic_tags_topics

    # BirdOldMerge.downloads
    
    # BirdOldMerge.emails
    # BirdOldMerge.emails_users

    # BirdOldMerge.posts

    # BirdOldMerge.meta_tags

    puts 'complete!'
  end

end
