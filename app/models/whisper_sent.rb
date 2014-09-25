class WhisperSent < ActiveRecord::Base
  def self.create_new_record(origin_id, target_id)
    w = WhisperSent.new
    w.origin_user_id = origin_id
    w.target_user_id = target_id
    w.whisper_time = Time.now
    w.save!
    return true
  end
end