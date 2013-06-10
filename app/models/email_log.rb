class EmailLog < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :email_type
  validates_presence_of :to_address

  before_create do
    # We only generate a reply
    if SiteSetting.reply_by_email_enabled?
      self.reply_key = SecureRandom.hex(16)
    end
  end

  after_create do
    # Update last_emailed_at if the user_id is present
    User.update_all("last_emailed_at = CURRENT_TIMESTAMP", id: user_id) if user_id.present?
  end

  def self.count_per_day(sinceDaysAgo = 30)
    where('created_at > ?', sinceDaysAgo.days.ago).group('date(created_at)').order('date(created_at)').count
  end
end

# == Schema Information
#
# Table name: email_logs
#
#  id         :integer          not null, primary key
#  to_address :string(255)      not null
#  email_type :string(255)      not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_email_logs_on_created_at              (created_at)
#  index_email_logs_on_user_id_and_created_at  (user_id,created_at)
#

