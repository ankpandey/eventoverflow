class User < ActiveRecord::Base
  has_secure_password

  has_many :events
  has_many :event_confirmations
  has_many :accepted_events,
            :through => :event_confirmations,
            :class_name => 'Event',
            :source => :event,
            :conditions  => {:decision => '1'}
  has_many :declined_events,
            :through => :event_confirmations,
            :class_name => 'Event',
            :source => :event,
            :conditions  => {:decision => '0'}
  has_many :possible_events,
            :through => :event_confirmations,
            :class_name => 'Event',
            :source => :event,
            :conditions  => {:decision => '2'}
  has_many :comments,
            :as => :commentable
  has_many :attended_events,
            :through => :event_confirmations,
            :class_name => 'Event',
            :source => :event

  attr_accessible :username, :password, :password_confirmation, :password_digest, :admin
  validates :username, :presence => true

  def upcoming_events
    now = Time.now
    Event.where("user_id = ? AND starts_at >= ?", self.id, now)
  end

  def past_events
    now = Time.now
    Event.where("user_id = ? AND starts_at < ?", self.id, now)
  end

  def commented_events
    commented_events = []
    self.comments.each do |comment|
      commented_events << Event.find(comment.event_id)
    end
    commented_events.uniq
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth["uid"]
      user.username = auth["info"]["name"]
      user.password = 'password'
    end
  end

  def self.find_or_create_user_by_uid auth
    User.find_by_uid(auth["uid"]) || User.create_with_omniauth(auth)
  end
end
