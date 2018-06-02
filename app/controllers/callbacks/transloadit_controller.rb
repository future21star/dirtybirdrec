class Callbacks::TransloaditController < ApplicationController
  # TODO: verify their access token
  skip_before_action :verify_authenticity_token

  def create
    obj = JSON.parse(params['transloadit'])

    if obj['ok']
      obj['results'].each do |step, status|
        # This updates the track so the 30 second samples work
        if step =~ /Track\_(\d)+\_sample_audio_encode/
          object_by_result_string(step).update!(sample_uri: status.first['ssl_url'])
        elsif step =~ /facebook_resize/
          object_by_result_string(step).update!(facebook_img: status.first['ssl_url'])
        elsif step =~ /^Track_\d+_waveform$/
          object_by_result_string(step).update!(waveform_image_uri: status.first['ssl_url'])
        end

        next unless step =~ /^(Track|Release)File_\d+$/

        # TODO: delete old TrackFiles and ReleaseFiles?
        job = object_by_result_string(step)
        job.complete!
        job.update!(
          # encoded_at: DateTime.now,
          s3_bucket: status.first['url'].split(%r{.s3.+.amazonaws.com/}).first.split(%r{/}).last,
          s3_key: status.first['url'].split(%r{.s3.+.amazonaws.com/}).last
        )

        # Set Release status
        job.release.complete! # TODO: what if we call track#encode
      end

      render nothing: true, status: 200 and return
    elsif obj['error']
      steps = JSON.parse(obj['params'])['steps']

      steps.each do |step, _details|
        next unless step =~ /^(Track|Release)File_\d+$/
        job = object_by_result_string(step)
        job.failed!
        job.release.failed! # TODO: what if we call track#encode
      end

      render nothing: true, status: 200 and return
    else
      render nothing: true, status: 500
    end
  end

  private

  def object_by_result_string(result_string)
    Object.const_get(result_string.split(/_/)[0]).find(result_string.split(/_/)[1])
  end
end
